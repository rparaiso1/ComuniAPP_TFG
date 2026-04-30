import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/documents/data/models/document_model.dart';
import 'package:comuniapp/features/documents/domain/entities/document_entity.dart';

void main() {
  final validJson = {
    'id': 'doc-1',
    'title': 'Acta de reunión',
    'file_url': 'https://example.com/files/acta.pdf',
    'file_type': 'pdf',
    'file_size': 204800,
    'uploaded_by_id': 'user-1',
    'uploaded_by': {'full_name': 'Admin User'},
    'description': 'Acta de la reunión del 15 de enero',
    'category': 'actas',
    'created_at': '2026-01-15T10:00:00.000',
    'updated_at': '2026-01-16T12:00:00.000',
  };

  group('DocumentModel', () {
    test('is a subclass of DocumentEntity', () {
      final model = DocumentModel.fromJson(validJson);
      expect(model, isA<DocumentEntity>());
    });
  });

  group('DocumentModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = DocumentModel.fromJson(validJson);
      expect(model.id, 'doc-1');
      expect(model.title, 'Acta de reunión');
      expect(model.fileUrl, 'https://example.com/files/acta.pdf');
      expect(model.fileType, 'pdf');
      expect(model.fileSize, 204800);
      expect(model.uploadedById, 'user-1');
      expect(model.uploadedByName, 'Admin User');
      expect(model.description, 'Acta de la reunión del 15 de enero');
      expect(model.category, 'actas');
      expect(model.createdAt, DateTime(2026, 1, 15, 10, 0));
      expect(model.updatedAt, DateTime(2026, 1, 16, 12, 0));
    });

    test('handles missing optional fields', () {
      final minimalJson = {
        'id': 'doc-2',
        'title': 'Doc',
        'file_url': 'https://example.com/f.pdf',
        'file_type': 'pdf',
        'uploaded_by_id': 'user-1',
        'created_at': '2026-01-01T00:00:00.000',
      };
      final model = DocumentModel.fromJson(minimalJson);
      expect(model.fileSize, isNull);
      expect(model.description, isNull);
      expect(model.category, isNull);
      expect(model.updatedAt, isNull);
    });

    test('defaults uploadedByName to "Usuario" when uploaded_by is null', () {
      final json = {...validJson};
      json.remove('uploaded_by');
      final model = DocumentModel.fromJson(json);
      expect(model.uploadedByName, 'Usuario');
    });

    test('defaults uploadedByName to "Usuario" when full_name is missing', () {
      final json = {...validJson, 'uploaded_by': <String, dynamic>{}};
      final model = DocumentModel.fromJson(json);
      expect(model.uploadedByName, 'Usuario');
    });

    test('defaults id, title, fileUrl, fileType to empty string when null', () {
      final json = <String, dynamic>{
        'created_at': '2026-01-01T00:00:00.000',
      };
      final model = DocumentModel.fromJson(json);
      expect(model.id, '');
      expect(model.title, '');
      expect(model.fileUrl, '');
      expect(model.fileType, '');
      expect(model.uploadedById, '');
    });

    test('parses updated_at as null when not provided', () {
      final json = {...validJson};
      json.remove('updated_at');
      final model = DocumentModel.fromJson(json);
      expect(model.updatedAt, isNull);
    });
  });

  group('DocumentModel.toJson', () {
    test('produces correct JSON map', () {
      final model = DocumentModel.fromJson(validJson);
      final json = model.toJson();
      expect(json['title'], 'Acta de reunión');
      expect(json['file_url'], 'https://example.com/files/acta.pdf');
      expect(json['file_type'], 'pdf');
      expect(json['file_size'], 204800);
      expect(json['description'], 'Acta de la reunión del 15 de enero');
      expect(json['category'], 'actas');
    });

    test('does not include id, uploadedById, or timestamps', () {
      final model = DocumentModel.fromJson(validJson);
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('uploaded_by_id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });

    test('includes null values for optional fields', () {
      final minimalJson = {
        'id': 'doc-2',
        'title': 'Doc',
        'file_url': 'https://example.com/f.pdf',
        'file_type': 'pdf',
        'created_at': '2026-01-01T00:00:00.000',
      };
      final model = DocumentModel.fromJson(minimalJson);
      final json = model.toJson();
      expect(json['file_size'], isNull);
      expect(json['description'], isNull);
      expect(json['category'], isNull);
    });
  });
}
