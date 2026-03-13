import 'package:equatable/equatable.dart';

class DocumentEntity extends Equatable {
  final String id;
  final String title;
  final String fileUrl;
  final String fileType;
  final int? fileSize;
  final String uploadedById;
  final String uploadedByName;
  final String? description;
  final String? category;
  final String? approvalStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DocumentEntity({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    required this.uploadedById,
    required this.uploadedByName,
    this.description,
    this.category,
    this.approvalStatus,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPendingApproval => approvalStatus == 'pending_approval';
  bool get isApproved => approvalStatus == 'approved' || approvalStatus == null;
  bool get isRejected => approvalStatus == 'rejected';

  @override
  List<Object?> get props => [
        id,
        title,
        fileUrl,
        fileType,
        fileSize,
        uploadedById,
        uploadedByName,
        description,
        category,
        approvalStatus,
        createdAt,
        updatedAt,
      ];

  String get fileSizeFormatted {
    if (fileSize == null) return 'Desconocido';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get fileExtension {
    return fileType.toUpperCase();
  }
}
