import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_organization.dart';
import '../../domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.avatar,
    required super.role,
    required super.communityId,
    super.dwellingId,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.organizations = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse organizations list
    final orgsList = <UserOrganization>[];
    String communityId = '';
    if (json['organizations'] != null && (json['organizations'] as List).isNotEmpty) {
      for (final org in json['organizations']) {
        orgsList.add(UserOrganization.fromJson(org as Map<String, dynamic>));
      }
      communityId = orgsList.first.organizationId;
    }

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      phone: json['phone'],
      avatar: json['avatar_url'],
      role: UserRole.fromString(json['role'] ?? 'neighbor'),
      communityId: communityId,
      dwellingId: json['dwelling'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      organizations: orgsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': name,
      'phone': phone,
      'avatar_url': avatar,
      'role': role.value,
      'community_id': communityId,
      'dwelling_id': dwellingId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
