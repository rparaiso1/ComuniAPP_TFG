import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/documents/domain/entities/document_entity.dart';

void main() {
  final baseDate = DateTime(2026, 1, 15);

  DocumentEntity createDoc({
    String id = 'doc-1',
    String title = 'Test Document',
    String fileUrl = 'https://example.com/file.pdf',
    String fileType = 'pdf',
    int? fileSize,
    String uploadedById = 'user-1',
    String uploadedByName = 'Test User',
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentEntity(
      id: id,
      title: title,
      fileUrl: fileUrl,
      fileType: fileType,
      fileSize: fileSize,
      uploadedById: uploadedById,
      uploadedByName: uploadedByName,
      description: description,
      category: category,
      createdAt: createdAt ?? baseDate,
      updatedAt: updatedAt,
    );
  }

  group('DocumentEntity constructor', () {
    test('creates instance with all required fields', () {
      final doc = createDoc();
      expect(doc.id, 'doc-1');
      expect(doc.title, 'Test Document');
      expect(doc.fileUrl, 'https://example.com/file.pdf');
      expect(doc.fileType, 'pdf');
      expect(doc.uploadedById, 'user-1');
      expect(doc.uploadedByName, 'Test User');
      expect(doc.createdAt, baseDate);
    });

    test('optional fields default to null', () {
      final doc = createDoc();
      expect(doc.fileSize, isNull);
      expect(doc.description, isNull);
      expect(doc.category, isNull);
      expect(doc.updatedAt, isNull);
    });

    test('stores optional fields when provided', () {
      final updated = DateTime(2026, 2, 1);
      final doc = createDoc(
        fileSize: 2048,
        description: 'A test document',
        category: 'actas',
        updatedAt: updated,
      );
      expect(doc.fileSize, 2048);
      expect(doc.description, 'A test document');
      expect(doc.category, 'actas');
      expect(doc.updatedAt, updated);
    });
  });

  group('fileSizeFormatted', () {
    test('returns "Desconocido" when fileSize is null', () {
      final doc = createDoc(fileSize: null);
      expect(doc.fileSizeFormatted, 'Desconocido');
    });

    test('returns bytes for size < 1024', () {
      expect(createDoc(fileSize: 0).fileSizeFormatted, '0B');
      expect(createDoc(fileSize: 1).fileSizeFormatted, '1B');
      expect(createDoc(fileSize: 512).fileSizeFormatted, '512B');
      expect(createDoc(fileSize: 1023).fileSizeFormatted, '1023B');
    });

    test('returns KB for size >= 1024 and < 1MB', () {
      expect(createDoc(fileSize: 1024).fileSizeFormatted, '1.0KB');
      expect(createDoc(fileSize: 1536).fileSizeFormatted, '1.5KB');
      expect(createDoc(fileSize: 10240).fileSizeFormatted, '10.0KB');
      expect(createDoc(fileSize: 1048575).fileSizeFormatted, '1024.0KB');
    });

    test('returns MB for size >= 1MB', () {
      expect(createDoc(fileSize: 1048576).fileSizeFormatted, '1.0MB');
      expect(createDoc(fileSize: 1572864).fileSizeFormatted, '1.5MB');
      expect(createDoc(fileSize: 10485760).fileSizeFormatted, '10.0MB');
      expect(createDoc(fileSize: 104857600).fileSizeFormatted, '100.0MB');
    });

    test('formats fractional KB correctly', () {
      // 2560 bytes = 2.5 KB
      expect(createDoc(fileSize: 2560).fileSizeFormatted, '2.5KB');
    });

    test('formats fractional MB correctly', () {
      // 3 * 1024 * 1024 + 512 * 1024 = 3670016 bytes = 3.5 MB
      expect(createDoc(fileSize: 3670016).fileSizeFormatted, '3.5MB');
    });
  });

  group('fileExtension', () {
    test('returns uppercase of fileType', () {
      expect(createDoc(fileType: 'pdf').fileExtension, 'PDF');
      expect(createDoc(fileType: 'docx').fileExtension, 'DOCX');
      expect(createDoc(fileType: 'xlsx').fileExtension, 'XLSX');
      expect(createDoc(fileType: 'jpg').fileExtension, 'JPG');
    });

    test('handles already uppercase fileType', () {
      expect(createDoc(fileType: 'PDF').fileExtension, 'PDF');
    });

    test('handles mixed case fileType', () {
      expect(createDoc(fileType: 'Pdf').fileExtension, 'PDF');
    });

    test('handles empty fileType', () {
      expect(createDoc(fileType: '').fileExtension, '');
    });
  });

  group('DocumentEntity Equatable', () {
    test('two entities with same props are equal', () {
      final d1 = createDoc();
      final d2 = createDoc();
      expect(d1, equals(d2));
    });

    test('two entities with different id are not equal', () {
      final d1 = createDoc(id: 'doc-1');
      final d2 = createDoc(id: 'doc-2');
      expect(d1, isNot(equals(d2)));
    });

    test('two entities with different fileSize are not equal', () {
      final d1 = createDoc(fileSize: 100);
      final d2 = createDoc(fileSize: 200);
      expect(d1, isNot(equals(d2)));
    });
  });
}
