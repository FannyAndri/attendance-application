class User {
  final String id;
  final String email;
  final String name;
  final String department;
  final String? profileImageUrl;
  final String role;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.department,
    this.profileImageUrl,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: json['role'] as String? ?? 'employee',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'department': department,
    'profileImageUrl': profileImageUrl,
    'role': role,
    'isActive': isActive,
  };

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? department,
    String? profileImageUrl,
    String? role,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      department: department ?? this.department,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
