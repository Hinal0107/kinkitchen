import 'menu_item.dart';

class CartItem {
  final int id;
  final int userId;
  final int restaurantId;
  final int? menuItemId;
  final int? addonId;
  int quantity;
  final MenuItem? menuItem;
  final MenuItem? addon;

  CartItem({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.menuItemId,
    this.addonId,
    required this.quantity,
    this.menuItem,
    this.addon,
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

    return CartItem(
      id: toInt(json['id']),
      userId: toInt(json['user_id']),
      restaurantId: toInt(json['restaurant_id']),
      menuItemId: toNullableInt(json['menu_item_id']),
      addonId: toNullableInt(json['addon_id']),
      quantity: toInt(json['quantity'] ?? 1),
      menuItem: json['menu_item'] != null ? MenuItem.fromJson(json['menu_item'] as Map<String, dynamic>) : null,
      addon: json['addon'] != null ? MenuItem.fromJson(json['addon'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'menu_item_id': menuItemId,
      'addon_id': addonId,
      'quantity': quantity,
      'menu_item': menuItem?.toJson(),
      'addon': addon?.toJson(),
    };
  }

  double get unitPrice => menuItem?.price ?? addon?.price ?? 0.0;
  double get totalPrice => unitPrice * quantity;
  String get name => menuItem?.name ?? addon?.name ?? 'Item';
}
