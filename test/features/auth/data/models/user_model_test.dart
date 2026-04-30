import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/auth/data/models/user_model.dart';
import 'package:comuniapp/features/auth/domain/entities/user_entity.dart';
import 'package:comuniapp/features/auth/domain/entities/user_role.dart';

void main() {
  final validJson = {
    'id': 'user-123',
    'email': 'admin1@tfg.com',
    'name': 'Admin User',
    'phone': '612345678',
    'avatar_url': 'https://img.com/avatar.png',
    'role': 'admin',
    'dwelling': '3B',
    'is_active': true,
    'created_at': '2026-01-15T10:30:00.000',
    'updated_at': '2026-02-20T14:00:00.000',
    'organizations': [
      {
        'organization_id': 'org-1',
        'organization_name': 'Jardines del Valle',
        'organization_code': 'JDV',
        'role': 'admin',
        'dwelling': '3B',
      },
      {
        'organization_id': 'org-2',
        'organization_name': 'Las Palmeras',
        'role': 'neighbor',
      },
    ],
  };

  group('UserModel', () {
    test('is a subclass of UserEntity', () {
      final model = UserModel.fromJson(validJson);
      expect(model, isA<UserEntity>());
    });
  });

  group('UserModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = UserModel.fromJson(validJson);
      expect(model.id, 'user-123');
      expect(model.email, 'admin1@tfg.com');
      expect(model.name, 'Admin User');
      expect(model.phone, '612345678');
      expect(model.avatar, 'https://img.com/avatar.png');
      expect(model.role, UserRole.admin);
      expect(model.dwellingId, '3B');
      expect(model.isActive, isTrue);
      expect(model.createdAt, DateTime(2026, 1, 15, 10, 30));
      expect(model.updatedAt, DateTime(2026, 2, 20, 14, 0));
    });

    test('parses organizations list correctly', () {
      final model = UserModel.fromJson(validJson);
      expect(model.organizations, hasLength(2));
      expect(model.organizations[0].organizationId, 'org-1');
      expect(model.organizations[0].organizationName, 'Jardines del Valle');
      expect(model.organizations[0].organizationCode, 'JDV');
      expect(model.organizations[1].organizationId, 'org-2');
      expect(model.organizations[1].organizationName, 'Las Palmeras');
    });

    test('sets communityId from first organization', () {
      final model = UserModel.fromJson(validJson);
      expect(model.communityId, 'org-1');
    });

    test('uses full_name as fallback for name', () {
      final json = {
        ...validJson,
        'name': null,
        'full_name': 'Full Name User',
      };
      final model = UserModel.fromJson(json);
      expect(model.name, 'Full Name User');
    });

    test('handles missing optional fields gracefully', () {
      final minimalJson = {
        'id': 'user-456',
        'email': 'test@tfg.com',
        'name': 'Test',
        'role': 'neighbor',
        'is_active': true,
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
        'organizations': <Map<String, dynamic>>[],
      };
      final model = UserModel.fromJson(minimalJson);
      expect(model.phone, isNull);
      expect(model.avatar, isNull);
      expect(model.dwellingId, isNull);
      expect(model.organizations, isEmpty);
      expect(model.communityId, '');
    });

    test('defaults id and email to empty string when null', () {
      final json = <String, dynamic>{
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
      };
      final model = UserModel.fromJson(json);
      expect(model.id, '');
      expect(model.email, '');
      expect(model.name, '');
    });

    test('defaults role to neighbor when missing', () {
      final json = <String, dynamic>{
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
      };
      final model = UserModel.fromJson(json);
      expect(model.role, UserRole.neighbor);
    });

    test('defaults is_active to true when missing', () {
      final json = <String, dynamic>{
        'created_at': '2026-01-01T00:00:00.000',
        'updated_at': '2026-01-01T00:00:00.000',
      };
      final model = UserModel.fromJson(json);
      expect(model.isActive, isTrue);
    });

    test('handles null organizations', () {
      final json = {
        ...validJson,
        'organizations': null,
      };
      final model = UserModel.fromJson(json);
      expect(model.organizations, isEmpty);
      expect(model.communityId, '');
    });

    test('parses president role', () {
      final json = {...validJson, 'role': 'president'};
      final model = UserModel.fromJson(json);
      expect(model.role, UserRole.president);
    });
  });

  group('UserModel.toJson', () {
    test('produces correct JSON map', () {
      final model = UserModel.fromJson(validJson);
      final json = model.toJson();
      expect(json['id'], 'user-123');
      expect(json['email'], 'admin1@tfg.com');
      expect(json['full_name'], 'Admin User');
      expect(json['phone'], '612345678');
      expect(json['avatar_url'], 'https://img.com/avatar.png');
      expect(json['role'], 'admin');
      expect(json['is_active'], isTrue);
      expect(json['created_at'], isA<String>());
      expect(json['updated_at'], isA<String>());
    });
  });
}
