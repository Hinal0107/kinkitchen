class Restaurant {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String description;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String openingTime;
  final String closingTime;
  final String? logoUrl;
  final String status; // 'active', 'inactive'

  Restaurant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.openingTime,
    required this.closingTime,
    this.logoUrl,
    required this.status,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unnamed Restaurant',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      openingTime: json['opening_time'] as String? ?? '',
      closingTime: json['closing_time'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? json['logo_url'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'logo_url': logoUrl,
      'status': status,
    };
  }
}
