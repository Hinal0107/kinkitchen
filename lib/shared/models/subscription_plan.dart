class SubscriptionPlan {
  final int id;
  final int restaurantId;
  final String title;
  final double price;
  final String duration;
  final int mealsCount;
  final String mealType;
  final String taxesAndDisc;
  final bool isPopular;
  final String status;

  SubscriptionPlan({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.price,
    required this.duration,
    required this.mealsCount,
    required this.mealType,
    required this.taxesAndDisc,
    required this.isPopular,
    required this.status,
  });

  /// Maximum validity days window (Weekly: 14 days, Monthly: 60 days)
  int get maxValidityDays {
    final d = duration.toLowerCase();
    final t = title.toLowerCase();
    if (d.contains('week') || t.contains('week') || mealsCount == 7) {
      return 14;
    } else if (d.contains('month') || t.contains('month') || mealsCount == 30) {
      return 60;
    }
    return mealsCount > 0 ? mealsCount * 2 : 14;
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
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
      return false;
    }

    return SubscriptionPlan(
      id: toInt(json['id']),
      restaurantId: toInt(json['restaurant_id']),
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Subscription Plan',
      price: toDouble(json['price']),
      duration: json['duration']?.toString() ?? json['duration_type']?.toString() ?? 'Monthly',
      mealsCount: toInt(json['meals_count'] ?? json['total_meals']),
      mealType: json['meal_type']?.toString() ?? 'Veg / Non-Veg',
      taxesAndDisc: json['taxes_and_disc']?.toString() ?? '',
      isPopular: toBool(json['is_popular']),
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'title': title,
      'price': price,
      'duration': duration,
      'meals_count': mealsCount,
      'meal_type': mealType,
      'taxes_and_disc': taxesAndDisc,
      'is_popular': isPopular ? 1 : 0,
      'status': status,
    };
  }
}
