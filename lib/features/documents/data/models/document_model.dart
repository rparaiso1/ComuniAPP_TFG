import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.title,
    required super.fileUrl,
    required super.fileType,
    super.fileSize,
    required super.uploadedById,
    required super.uploadedByName,
    super.description,
    super.category,
    super.approvalStatus,
    required super.createdAt,
    super.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileType: json['file_type'] ?? '',
      fileSize: json['file_size'],
      uploadedById: json['uploaded_by_id'] ?? '',
      uploadedByName: json['uploaded_by']?['full_name'] ?? json['uploaded_by_name'] ?? 'Usuario',
      description: json['description'],
      category: json['category'],
      approvalStatus: json['approval_status'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': super.title,
      'file_url': super.fileUrl,
      'file_type': super.fileType,
      'file_size': super.fileSize,
      'description': super.description,
      'category': super.category,
    };
  }
}
