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
  final String status;

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
    int toInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return Restaurant(
      id: toInt(json['id']),
      name: json['name']?.toString() ?? 'Unnamed Restaurant',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      openingTime: json['opening_time']?.toString() ?? '',
      closingTime: json['closing_time']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? json['logo_url']?.toString() ?? json['logo']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
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
