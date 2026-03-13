import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/services/org_selector_service.dart';
import '../../data/datasources/document_remote_datasource.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../../../../core/utils/paginated_state.dart';

// Repository provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authDataSource = ref.watch(authRemoteDataSourceProvider);
  
  final activeOrgId = ref.watch(activeOrgIdProvider);
  final remoteDataSource = DocumentRemoteDataSourceImpl(
    client: httpClient,
    getToken: () => authDataSource.accessToken ?? '',
    getOrgId: () => activeOrgId,
  );

  return DocumentRepositoryImpl(remoteDataSource: remoteDataSource);
});

// State class
class DocumentState with PaginatedState {
  final List<DocumentEntity> documents;
  final bool isLoading;
  final String? error;
  final bool isUploading;
  final String? selectedCategory;
  @override
  final bool isLoadingMore;
  @override
  final bool hasMore;
  @override
  final int currentSkip;

  DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.isUploading = false,
    this.selectedCategory,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentSkip = 0,
  });

  DocumentState copyWith({
    List<DocumentEntity>? documents,
    bool? isLoading,
    String? error,
    bool? isUploading,
    String? selectedCategory,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentSkip,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUploading: isUploading ?? this.isUploading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }
}

// Controller
class DocumentController extends Notifier<DocumentState> {
  late DocumentRepository repository;
  String? _lastCategory;

  @override
  DocumentState build() {
    repository = ref.watch(documentRepositoryProvider);
    return DocumentState();
  }

  Future<void> loadDocuments({String? category}) async {
    _lastCategory = category;
    state = state.copyWith(isLoading: true, error: null, selectedCategory: category, currentSkip: 0, hasMore: true);
    try {
      final documents = await repository.getDocuments(skip: 0, limit: kDefaultPageSize, category: category);
      state = state.copyWith(
        documents: documents,
        isLoading: false,
        currentSkip: documents.length,
        hasMore: documents.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final newDocuments = await repository.getDocuments(
        skip: state.currentSkip,
        limit: kDefaultPageSize,
        category: _lastCategory,
      );
      state = state.copyWith(
        documents: [...state.documents, ...newDocuments],
        isLoadingMore: false,
        currentSkip: state.currentSkip + newDocuments.length,
        hasMore: newDocuments.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadDocument({
    required String title,
    required String fileUrl,
    required String fileType,
    int? fileSize,
    String? description,
    String? category,
  }) async {
    state = state.copyWith(isUploading: true, error: null);
    try {
      final newDocument = await repository.uploadDocument(
        title: title,
        fileUrl: fileUrl,
        fileType: fileType,
        fileSize: fileSize,
        description: description,
        category: category,
      );
      state = state.copyWith(
        documents: [newDocument, ...state.documents],
        isUploading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await repository.deleteDocument(documentId);
      state = state.copyWith(
        documents: state.documents.where((d) => d.id != documentId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String title,
    String? description,
    String? category,
  }) async {
    state = state.copyWith(isUploading: true, error: null);
    try {
      final newDocument = await repository.uploadFile(
        fileBytes: fileBytes,
        fileName: fileName,
        title: title,
        description: description,
        category: category,
      );
      state = state.copyWith(
        documents: [newDocument, ...state.documents],
        isUploading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> approveDocument(String documentId, {required bool approved, String? rejectionReason}) async {
    try {
      final updated = await repository.approveDocument(documentId, approved: approved, rejectionReason: rejectionReason);
      state = state.copyWith(
        documents: state.documents
            .map((d) => d.id == documentId ? updated : d)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Controller provider
final documentControllerProvider =
    NotifierProvider<DocumentController, DocumentState>(
  () => DocumentController(),
);
