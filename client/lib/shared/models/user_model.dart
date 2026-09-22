class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String role; // requester, operator, team_lead, manager, administrator
  final String authProvider; // password, google
  final String? site;
  final String availabilityStatus; // available, away, offline
  final bool emailVerified;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    required this.authProvider,
    this.site,
    required this.availabilityStatus,
    required this.emailVerified,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      role: json['role'] ?? 'requester',
      authProvider: json['auth_provider'] ?? 'password',
      site: json['site'],
      availabilityStatus: json['availability_status'] ?? 'available',
      emailVerified: json['email_verified'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'auth_provider': authProvider,
      'site': site,
      'availability_status': availabilityStatus,
      'email_verified': emailVerified,
      'is_active': isActive,
    };
  }
}
