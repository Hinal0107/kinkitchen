class MenuItem {
  final int id;
  final int categoryId;
  final int restaurantId;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final String vegType; // 'VEG', 'NON_VEG', 'JAIN'
  final bool availability;
  final String status; // 'ACTIVE', 'INACTIVE'
  final String? imageUrl;
  final String? scheduleDate;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.vegType,
    required this.availability,
    required this.status,
    this.imageUrl,
    this.scheduleDate,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
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

    bool toBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return true;
    }

    return MenuItem(
      id: toInt(json['id']),
      categoryId: toInt(json['category_id']),
      restaurantId: toInt(json['restaurant_id']),
      name: json['name']?.toString() ?? 'Unnamed Item',
      description: json['description']?.toString() ?? '',
      price: toDouble(json['price']),
      discountPrice: toDouble(json['discount_price']),
      vegType: json['veg_type']?.toString() ?? 'VEG',
      availability: toBool(json['availability']),
      status: json['status']?.toString() ?? 'ACTIVE',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? json['image']?.toString(),
      scheduleDate: json['schedule_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'veg_type': vegType,
      'availability': availability ? 1 : 0,
      'status': status,
      'image_url': imageUrl,
      'schedule_date': scheduleDate,
    };
  }
}
