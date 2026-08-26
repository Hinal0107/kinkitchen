import 'menu_item.dart';
import 'daily_meal_item.dart';

class CartItem {
  final int id;
  final int userId;
  final int restaurantId;
  final int? menuItemId;
  final int? addonId;
  final int? dailyMealId;
  int quantity;
  final MenuItem? menuItem;
  final MenuItem? addon;
  final DailyMealItem? dailyMeal;
  final double? customUnitPrice;

  CartItem({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.menuItemId,
    this.addonId,
    this.dailyMealId,
    required this.quantity,
    this.menuItem,
    this.addon,
    this.dailyMeal,
    this.customUnitPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
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

    double? toNullableDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return CartItem(
      id: toInt(json['id']),
      userId: toInt(json['user_id']),
      restaurantId: toInt(json['restaurant_id']),
      menuItemId: toNullableInt(json['menu_item_id']),
      addonId: toNullableInt(json['addon_id']),
      dailyMealId: toNullableInt(json['daily_meal_id']),
      quantity: toInt(json['quantity'] ?? 1),
      menuItem: json['menu_item'] != null ? MenuItem.fromJson(json['menu_item'] as Map<String, dynamic>) : null,
      addon: json['addon'] != null ? MenuItem.fromJson(json['addon'] as Map<String, dynamic>) : null,
      dailyMeal: json['daily_meal'] != null ? DailyMealItem.fromJson(json['daily_meal'] as Map<String, dynamic>) : null,
      customUnitPrice: toNullableDouble(json['price'] ?? json['unit_price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'menu_item_id': menuItemId,
      'addon_id': addonId,
      'daily_meal_id': dailyMealId,
      'quantity': quantity,
      'menu_item': menuItem?.toJson(),
      'addon': addon?.toJson(),
      'daily_meal': dailyMeal?.toJson(),
      'unit_price': unitPrice,
    };
  }

  double get unitPrice {
    if (customUnitPrice != null && customUnitPrice! > 0) return customUnitPrice!;
    if (dailyMeal != null) return dailyMeal!.discountPrice > 0 ? dailyMeal!.discountPrice : dailyMeal!.price;
    if (menuItem != null) return menuItem!.discountPrice > 0 ? menuItem!.discountPrice : menuItem!.price;
    if (addon != null) return addon!.discountPrice > 0 ? addon!.discountPrice : addon!.price;
    return 0.0;
  }

  double get totalPrice => unitPrice * quantity;

  double getTaxAmount(double taxPercentage) => (totalPrice * taxPercentage) / 100;

  double getFinalAmount(double taxPercentage) => totalPrice + getTaxAmount(taxPercentage);

  String get name => menuItem?.name ?? dailyMeal?.name ?? addon?.name ?? 'Item';
}
