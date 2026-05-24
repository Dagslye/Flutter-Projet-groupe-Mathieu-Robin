class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'customer',
        avatar: json['avatar'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatar': avatar,
      };
}
