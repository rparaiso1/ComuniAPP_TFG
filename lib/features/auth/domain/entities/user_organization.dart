import 'package:equatable/equatable.dart';

/// Represents an organization the user belongs to
class UserOrganization extends Equatable {
  final String organizationId;
  final String organizationName;
  final String? organizationCode;
  final String role;
  final String? dwelling;

  const UserOrganization({
    required this.organizationId,
    required this.organizationName,
    this.organizationCode,
    required this.role,
    this.dwelling,
  });

  factory UserOrganization.fromJson(Map<String, dynamic> json) {
    return UserOrganization(
      organizationId: json['organization_id'] ?? json['org_id'] ?? '',
      organizationName: json['organization_name'] ?? json['org_name'] ?? '',
      organizationCode: json['organization_code'] ?? json['org_code'],
      role: json['role'] ?? 'neighbor',
      dwelling: json['dwelling'],
    );
  }

  @override
  List<Object?> get props => [organizationId, organizationName, role];
}
