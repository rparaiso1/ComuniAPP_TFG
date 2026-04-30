import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/features/auth/domain/entities/user_entity.dart';
import 'package:comuniapp/features/auth/domain/entities/user_role.dart';
import 'package:comuniapp/features/auth/domain/entities/user_organization.dart';

void main() {
  final now = DateTime(2026, 1, 15, 10, 30);
  final later = DateTime(2026, 2, 20, 14, 0);

  UserEntity createUser({
    String id = '1',
    String email = 'test@tfg.com',
    String name = 'Test User',
    String? phone,
    String? avatar,
    UserRole role = UserRole.neighbor,
    String communityId = 'org-1',
    String? dwellingId,
    bool isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserOrganization> organizations = const [],
  }) {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      avatar: avatar,
      role: role,
      communityId: communityId,
      dwellingId: dwellingId,
      isActive: isActive,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? later,
      organizations: organizations,
    );
  }

  group('UserEntity constructor', () {
    test('creates instance with all required fields', () {
      final user = createUser();
      expect(user.id, '1');
      expect(user.email, 'test@tfg.com');
      expect(user.name, 'Test User');
      expect(user.role, UserRole.neighbor);
      expect(user.communityId, 'org-1');
      expect(user.isActive, isTrue);
      expect(user.createdAt, now);
      expect(user.updatedAt, later);
    });

    test('optional fields default to null', () {
      final user = createUser();
      expect(user.phone, isNull);
      expect(user.avatar, isNull);
      expect(user.dwellingId, isNull);
    });

    test('organizations defaults to empty list', () {
      final user = createUser();
      expect(user.organizations, isEmpty);
    });

    test('stores phone and avatar when provided', () {
      final user = createUser(phone: '612345678', avatar: 'https://img.com/a.png');
      expect(user.phone, '612345678');
      expect(user.avatar, 'https://img.com/a.png');
    });

    test('stores dwellingId when provided', () {
      final user = createUser(dwellingId: 'dwelling-1');
      expect(user.dwellingId, 'dwelling-1');
    });

    test('stores organizations list', () {
      final orgs = [
        const UserOrganization(
          organizationId: 'org-1',
          organizationName: 'Jardines del Valle',
          role: 'admin',
        ),
        const UserOrganization(
          organizationId: 'org-2',
          organizationName: 'Las Palmeras',
          role: 'neighbor',
        ),
      ];
      final user = createUser(organizations: orgs);
      expect(user.organizations, hasLength(2));
      expect(user.organizations.first.organizationName, 'Jardines del Valle');
      expect(user.organizations.last.organizationName, 'Las Palmeras');
    });
  });

  group('UserEntity Equatable', () {
    test('two entities with same props are equal', () {
      final u1 = createUser();
      final u2 = createUser();
      expect(u1, equals(u2));
    });

    test('two entities with different id are not equal', () {
      final u1 = createUser(id: '1');
      final u2 = createUser(id: '2');
      expect(u1, isNot(equals(u2)));
    });

    test('two entities with different email are not equal', () {
      final u1 = createUser(email: 'a@tfg.com');
      final u2 = createUser(email: 'b@tfg.com');
      expect(u1, isNot(equals(u2)));
    });

    test('two entities with different role are not equal', () {
      final u1 = createUser(role: UserRole.admin);
      final u2 = createUser(role: UserRole.neighbor);
      expect(u1, isNot(equals(u2)));
    });
  });

  group('UserRole getters', () {
    test('isAdmin is true only for admin role', () {
      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.president.isAdmin, isFalse);
      expect(UserRole.neighbor.isAdmin, isFalse);
    });

    test('isPresident is true only for president role', () {
      expect(UserRole.president.isPresident, isTrue);
      expect(UserRole.admin.isPresident, isFalse);
      expect(UserRole.neighbor.isPresident, isFalse);
    });

    test('isNeighbor is true only for neighbor role', () {
      expect(UserRole.neighbor.isNeighbor, isTrue);
      expect(UserRole.admin.isNeighbor, isFalse);
      expect(UserRole.president.isNeighbor, isFalse);
    });

    test('isAdminOrPresident is true for admin and president', () {
      expect(UserRole.admin.isAdminOrPresident, isTrue);
      expect(UserRole.president.isAdminOrPresident, isTrue);
      expect(UserRole.neighbor.isAdminOrPresident, isFalse);
    });
  });

  group('UserRole.value', () {
    test('returns correct string for each role', () {
      expect(UserRole.admin.value, 'admin');
      expect(UserRole.president.value, 'president');
      expect(UserRole.neighbor.value, 'neighbor');
    });
  });

  group('UserRole.displayName', () {
    test('returns correct display name', () {
      expect(UserRole.admin.displayName, 'Administrador');
      expect(UserRole.president.displayName, 'Presidente');
      expect(UserRole.neighbor.displayName, 'Vecino');
    });
  });

  group('UserRole.fromString', () {
    test('parses standard role strings', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('president'), UserRole.president);
      expect(UserRole.fromString('neighbor'), UserRole.neighbor);
    });

    test('is case-insensitive', () {
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
      expect(UserRole.fromString('President'), UserRole.president);
      expect(UserRole.fromString('NEIGHBOR'), UserRole.neighbor);
    });

    test('maps legacy roles to neighbor', () {
      expect(UserRole.fromString('owner'), UserRole.neighbor);
      expect(UserRole.fromString('tenant'), UserRole.neighbor);
      expect(UserRole.fromString('family'), UserRole.neighbor);
      expect(UserRole.fromString('student'), UserRole.neighbor);
    });

    test('maps teacher to president', () {
      expect(UserRole.fromString('teacher'), UserRole.president);
    });

    test('defaults to neighbor for unknown roles', () {
      expect(UserRole.fromString('unknown'), UserRole.neighbor);
      expect(UserRole.fromString('superuser'), UserRole.neighbor);
      expect(UserRole.fromString(''), UserRole.neighbor);
    });
  });

  group('UserRole permissions', () {
    test('only admin can manage users', () {
      expect(UserRole.admin.canManageUsers, isTrue);
      expect(UserRole.president.canManageUsers, isFalse);
      expect(UserRole.neighbor.canManageUsers, isFalse);
    });

    test('admin and president can manage invitations', () {
      expect(UserRole.admin.canManageInvitations, isTrue);
      expect(UserRole.president.canManageInvitations, isTrue);
      expect(UserRole.neighbor.canManageInvitations, isFalse);
    });

    test('admin and president can manage documents', () {
      expect(UserRole.admin.canManageDocuments, isTrue);
      expect(UserRole.president.canManageDocuments, isTrue);
      expect(UserRole.neighbor.canManageDocuments, isFalse);
    });

    test('admin and president can approve bookings', () {
      expect(UserRole.admin.canApproveBookings, isTrue);
      expect(UserRole.president.canApproveBookings, isTrue);
      expect(UserRole.neighbor.canApproveBookings, isFalse);
    });

    test('all roles can create bookings', () {
      expect(UserRole.admin.canCreateBookings, isTrue);
      expect(UserRole.president.canCreateBookings, isTrue);
      expect(UserRole.neighbor.canCreateBookings, isTrue);
    });

    test('all roles can create incidents', () {
      expect(UserRole.admin.canCreateIncidents, isTrue);
      expect(UserRole.president.canCreateIncidents, isTrue);
      expect(UserRole.neighbor.canCreateIncidents, isTrue);
    });

    test('all roles can view documents', () {
      expect(UserRole.admin.canViewDocuments, isTrue);
      expect(UserRole.president.canViewDocuments, isTrue);
      expect(UserRole.neighbor.canViewDocuments, isTrue);
    });

    test('admin and president can delete any post', () {
      expect(UserRole.admin.canDeleteAnyPost, isTrue);
      expect(UserRole.president.canDeleteAnyPost, isTrue);
      expect(UserRole.neighbor.canDeleteAnyPost, isFalse);
    });

    test('admin and president can manage zones', () {
      expect(UserRole.admin.canManageZones, isTrue);
      expect(UserRole.president.canManageZones, isTrue);
      expect(UserRole.neighbor.canManageZones, isFalse);
    });
  });

  group('UserOrganization', () {
    test('creates instance with required fields', () {
      const org = UserOrganization(
        organizationId: 'org-1',
        organizationName: 'Jardines del Valle',
        role: 'admin',
      );
      expect(org.organizationId, 'org-1');
      expect(org.organizationName, 'Jardines del Valle');
      expect(org.role, 'admin');
      expect(org.organizationCode, isNull);
      expect(org.dwelling, isNull);
    });

    test('creates instance with all fields', () {
      const org = UserOrganization(
        organizationId: 'org-1',
        organizationName: 'Jardines del Valle',
        organizationCode: 'JDV',
        role: 'president',
        dwelling: '3B',
      );
      expect(org.organizationCode, 'JDV');
      expect(org.dwelling, '3B');
    });

    group('fromJson', () {
      test('parses standard keys', () {
        final org = UserOrganization.fromJson({
          'organization_id': 'org-1',
          'organization_name': 'Test Org',
          'organization_code': 'TO',
          'role': 'admin',
          'dwelling': '1A',
        });
        expect(org.organizationId, 'org-1');
        expect(org.organizationName, 'Test Org');
        expect(org.organizationCode, 'TO');
        expect(org.role, 'admin');
        expect(org.dwelling, '1A');
      });

      test('parses alternative keys (org_id, org_name, org_code)', () {
        final org = UserOrganization.fromJson({
          'org_id': 'org-2',
          'org_name': 'Alt Org',
          'org_code': 'AO',
          'role': 'neighbor',
        });
        expect(org.organizationId, 'org-2');
        expect(org.organizationName, 'Alt Org');
        expect(org.organizationCode, 'AO');
      });

      test('defaults to empty string and neighbor when keys missing', () {
        final org = UserOrganization.fromJson({});
        expect(org.organizationId, '');
        expect(org.organizationName, '');
        expect(org.role, 'neighbor');
        expect(org.dwelling, isNull);
      });
    });

    group('Equatable', () {
      test('two orgs with same props are equal', () {
        const a = UserOrganization(
          organizationId: 'o1',
          organizationName: 'Org',
          role: 'admin',
        );
        const b = UserOrganization(
          organizationId: 'o1',
          organizationName: 'Org',
          role: 'admin',
        );
        expect(a, equals(b));
      });

      test('two orgs with different ids are not equal', () {
        const a = UserOrganization(
          organizationId: 'o1',
          organizationName: 'Org',
          role: 'admin',
        );
        const b = UserOrganization(
          organizationId: 'o2',
          organizationName: 'Org',
          role: 'admin',
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}
