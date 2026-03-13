import 'dart:typed_data';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  Future<List<DocumentEntity>> getDocuments({int skip = 0, int limit = 100, String? category});
  Future<DocumentEntity> getDocument(String documentId);
  Future<DocumentEntity> uploadDocument({
    required String title,
    required String fileUrl,
    required String fileType,
    int? fileSize,
    String? description,
    String? category,
  });
  Future<DocumentEntity> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String title,
    String? description,
    String? category,
  });
  Future<void> deleteDocument(String documentId);
  Future<DocumentEntity> approveDocument(String documentId, {required bool approved, String? rejectionReason});
}
