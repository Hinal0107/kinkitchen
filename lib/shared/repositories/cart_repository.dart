import 'package:kinkitchen/app/constants/api_constants.dart';
import 'package:kinkitchen/core/network/api_client.dart';
import 'package:kinkitchen/shared/models/cart_item.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // 1. Get Cart
  Future<List<CartItem>> getCart() async {
    final response = await _apiClient.get(ApiConfig.cart);
    final data = response['data'] ?? response['cart'] ?? response['items'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('items') ? data['items'] : [])) ?? [];
    return list.map((json) => CartItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 2. Add Item / Addon to Cart
  Future<CartItem> addItem({
    required int restaurantId,
    int? menuItemId,
    int? addonId,
    int quantity = 1,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.cartItems,
      body: {
        'restaurant_id': restaurantId,
        'menu_item_id': menuItemId,
        'addon_id': addonId,
        'quantity': quantity,
      },
    );
    final data = response['data'] ?? response['cart_item'] ?? response;
    return CartItem.fromJson(data as Map<String, dynamic>);
  }

  // 3. Update Cart Item Quantity
  Future<CartItem> updateQuantity(int cartItemId, int quantity) async {
    final response = await _apiClient.put(
      '${ApiConfig.cartItems}/$cartItemId',
      body: {'quantity': quantity},
    );
    final data = response['data'] ?? response['cart_item'] ?? response;
    return CartItem.fromJson(data as Map<String, dynamic>);
  }

  // 4. Remove Cart Item
  Future<void> removeItem(int cartItemId) async {
    await _apiClient.delete('${ApiConfig.cartItems}/$cartItemId');
  }

  // 5. Clear Entire Cart
  Future<void> clearCart() async {
    await _apiClient.delete(ApiConfig.cart);
  }
}
