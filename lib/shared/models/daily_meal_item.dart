class DailyMealItem {
  final int id;
  final int restaurantId;
  final String date;
  final String name;
  final String description;
  final String? image;
  final double price;
  final double discountPrice;
  final String vegType;
  final String mealType; // 'TODAY', 'TOMORROW', 'WEEKLY'
  final List<int> addons;
  final bool availability;
  final String status;

  DailyMealItem({
    required this.id,
    required this.restaurantId,
    required this.date,
    required this.name,
    required this.description,
    this.image,
    required this.price,
    required this.discountPrice,
    required this.vegType,
    required this.mealType,
    required this.addons,
    required this.availability,
    required this.status,
  });

  factory DailyMealItem.fromJson(Map<String, dynamic> json) {
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

    String parseDate(dynamic val) {
      if (val == null) return '';
      final str = val.toString().trim();
      if (str.contains('T')) {
        return str.split('T')[0]; // e.g. "2026-08-26T00:00:00.000000Z" -> "2026-08-26"
      }
      return str;
    }

    List<int> parseAddons(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) => toInt(e)).where((e) => e > 0).toList();
      }
      if (raw is String) {
        return raw.split(',').map((e) => int.tryParse(e.trim()) ?? 0).where((e) => e > 0).toList();
      }
      return [];
    }

    return DailyMealItem(
      id: toInt(json['id']),
      restaurantId: toInt(json['restaurant_id']),
      date: parseDate(json['date']),
      name: json['name']?.toString() ?? 'Daily Meal',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? json['image_url']?.toString(),
      price: toDouble(json['price']),
      discountPrice: toDouble(json['discount_price']),
      vegType: json['veg_type']?.toString() ?? 'VEG',
      mealType: json['meal_type']?.toString() ?? 'TODAY',
      addons: parseAddons(json['addons']),
      availability: toBool(json['availability']),
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'date': date,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'discount_price': discountPrice,
      'veg_type': vegType,
      'meal_type': mealType,
      'addons': addons,
      'availability': availability ? 1 : 0,
      'status': status,
    };
  }
}
