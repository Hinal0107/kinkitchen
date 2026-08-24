class User {
  final int id;
  final String uid; // Firebase Auth UID
  final String name;
  final String email;
  final String phone;
  final String role; // 'restaurant' or 'customer'

  User({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      uid: json['firebase_uid'] as String? ?? json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: (json['role'] as String? ?? 'customer').toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}
