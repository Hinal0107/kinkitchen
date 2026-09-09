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
  final double taxPercentage;
  final double? latitude;
  final double? longitude;
  final double? serviceRadiusKm;
  final String? bankName;
  final String? accountHolderName;
  final String? accountNumber;
  final String? sortCode;
  final String? iban;

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
    this.taxPercentage = 0.0,
    this.latitude,
    this.longitude,
    this.serviceRadiusKm,
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.sortCode,
    this.iban,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double toDouble(dynamic val) {
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    double? toNullableDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
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
      taxPercentage: toDouble(json['tax_percentage'] ?? json['gst_percentage'] ?? json['tax_rate']),
      latitude: toNullableDouble(json['latitude'] ?? json['lat']),
      longitude: toNullableDouble(json['longitude'] ?? json['lng']),
      serviceRadiusKm: toNullableDouble(json['service_radius_km'] ?? json['service_radius']),
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString(),
      accountHolderName: json['account_holder_name']?.toString() ?? json['accountHolderName']?.toString(),
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString(),
      sortCode: json['sort_code']?.toString() ?? json['sortCode']?.toString(),
      iban: json['iban']?.toString(),
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
      'tax_percentage': taxPercentage,
      'latitude': latitude,
      'longitude': longitude,
      'service_radius_km': serviceRadiusKm,
      'bank_name': bankName,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'sort_code': sortCode,
      'iban': iban,
    };
  }
}
