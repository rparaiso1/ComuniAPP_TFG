import 'package:equatable/equatable.dart';
import 'user_organization.dart';
import 'user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final UserRole role;
  final String communityId;
  final String? dwellingId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<UserOrganization> organizations;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    required this.role,
    required this.communityId,
    this.dwellingId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.organizations = const [],
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        avatar,
        role,
        communityId,
        dwellingId,
        isActive,
        createdAt,
        updatedAt,
        organizations,
      ];
}
