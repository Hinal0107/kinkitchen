class Address {
  final int id;
  final int userId;
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double? toNullableDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    bool toBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    return Address(
      id: toInt(json['id']),
      userId: toInt(json['user_id']),
      label: json['label']?.toString() ?? 'Home',
      line1: json['line1']?.toString() ?? json['address_line_1']?.toString() ?? '',
      line2: json['line2']?.toString() ?? json['address_line_2']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      latitude: toNullableDouble(json['latitude']),
      longitude: toNullableDouble(json['longitude']),
      isDefault: toBool(json['is_default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
    };
  }
}
