class UserModel {
  final int? id;
  final String name;
  final String? rollNumber;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final String role; // 'admin', 'student', 'guard'

  UserModel({
    this.id,
    required this.name,
    this.rollNumber,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roll_number': rollNumber,
      'email': email,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      rollNumber: map['roll_number'] as String?,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      passwordSalt: map['password_salt'] as String,
      role: map['role'] as String,
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? rollNumber,
    String? email,
    String? passwordHash,
    String? passwordSalt,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      role: role ?? this.role,
    );
  }
}
