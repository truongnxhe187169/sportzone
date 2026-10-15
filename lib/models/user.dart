/// Model đại diện cho người dùng trong hệ thống
class User {
  final int id;
  final String name;
  final String email;
  final String password; // SHA-256 hash
  final String? phone;
  final String? avatar; // local file path hoặc URL
  final String createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.avatar,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
        password: map['password'] as String,
        phone: map['phone'] as String?,
        avatar: map['avatar'] as String?,
        createdAt: map['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'avatar': avatar,
        'created_at': createdAt,
      };

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? avatar,
    String? createdAt,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        phone: phone ?? this.phone,
        avatar: avatar ?? this.avatar,
        createdAt: createdAt ?? this.createdAt,
      );
}
