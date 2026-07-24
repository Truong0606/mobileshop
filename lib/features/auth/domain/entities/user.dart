import 'package:equatable/equatable.dart';

/// Represents an authenticated user of the application.
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role = 'Customer',
    required this.createdAt,
  });

  /// Whether this user has the Admin role.
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Whether this user has the Customer role.
  bool get isCustomer => role.toLowerCase() == 'customer';

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether this user has the BusinessOwner role.
  bool get isBusinessOwner => role.toLowerCase() == 'businessowner';

  @override
  List<Object?> get props => [id, name, email, avatarUrl, role, createdAt];
}
