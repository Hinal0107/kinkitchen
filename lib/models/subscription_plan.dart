class SubscriptionPlan {
  final int id;
  final int restaurantId;
  final String title;
  final double price;
  final String duration; // 'Weekly', 'Monthly', '15 Days'
  final int mealsCount;
  final String mealType; // 'Veg / Non-Veg', 'Pure Veg'
  final String taxesAndDisc;
  final bool isPopular;
  final String status; // 'active', 'inactive'

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

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as String? ?? 'Monthly',
      mealsCount: json['meals_count'] as int? ?? 30,
      mealType: json['meal_type'] as String? ?? 'Veg / Non-Veg',
      taxesAndDisc: json['taxes_and_disc'] as String? ?? '',
      isPopular: (json['is_popular'] is int) 
          ? (json['is_popular'] as int) == 1 
          : (json['is_popular'] as bool? ?? false),
      status: json['status'] as String? ?? 'active',
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
