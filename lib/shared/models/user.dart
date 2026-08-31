class User {
  final int id;
  final String uid; // Firebase Auth UID
  final String name;
  final String email;
  final String phone;
  final String role; // 'restaurant' or 'customer'
  final String? avatarUrl;
  final int? selectedRestaurantId;

  User({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.selectedRestaurantId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    int? toNullableInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    return User(
      id: toInt(json['id']),
      uid: json['firebase_uid']?.toString() ?? json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: (json['role']?.toString() ?? 'customer').toLowerCase(),
      avatarUrl: json['profile_image']?.toString() ?? json['avatar_url']?.toString() ?? json['avatar']?.toString() ?? json['profile_photo_url']?.toString(),
      selectedRestaurantId: toNullableInt(json['selected_restaurant_id'] ?? json['restaurant_id']),
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
      'avatar_url': avatarUrl,
      'selected_restaurant_id': selectedRestaurantId,
    };
  }
}
