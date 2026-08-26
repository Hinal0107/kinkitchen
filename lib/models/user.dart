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
    int toInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return User(
      id: toInt(json['id']),
      uid: json['firebase_uid']?.toString() ?? json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: (json['role']?.toString() ?? 'customer').toLowerCase(),
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
