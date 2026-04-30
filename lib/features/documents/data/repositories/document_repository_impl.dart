import 'dart:typed_data';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  DocumentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DocumentEntity>> getDocuments({int skip = 0, int limit = 100, String? category}) async {
    return (await remoteDataSource.getDocuments(skip: skip, limit: limit, category: category)).cast<DocumentEntity>();
  }

  @override
  Future<DocumentEntity> getDocument(String documentId) async {
    return await remoteDataSource.getDocument(documentId) as DocumentEntity;
  }

  @override
  Future<DocumentEntity> uploadDocument({
    required String title,
    required String fileUrl,
    required String fileType,
    int? fileSize,
    String? description,
    String? category,
  }) async {
    return await remoteDataSource.uploadDocument(
      title: title,
      fileUrl: fileUrl,
      fileType: fileType,
      fileSize: fileSize,
      description: description,
      category: category,
    ) as DocumentEntity;
  }

  @override
  Future<DocumentEntity> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String title,
    String? description,
    String? category,
  }) async {
    return await remoteDataSource.uploadFile(
      fileBytes: fileBytes,
      fileName: fileName,
      title: title,
      description: description,
      category: category,
    ) as DocumentEntity;
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await remoteDataSource.deleteDocument(documentId);
  }

  @override
  Future<DocumentEntity> approveDocument(String documentId, {required bool approved, String? rejectionReason}) async {
    return await remoteDataSource.approveDocument(documentId, approved: approved, rejectionReason: rejectionReason) as DocumentEntity;
  }
}
