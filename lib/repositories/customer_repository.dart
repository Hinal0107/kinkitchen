import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/restaurant.dart';
import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../models/subscription_plan.dart';
import '../models/order.dart';

class CustomerRepository {
  final ApiClient _apiClient;

  CustomerRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // 1. Browse Active Restaurants
  Future<List<Restaurant>> getRestaurants() async {
    final response = await _apiClient.get(ApiConfig.customerRestaurants);
    final data = response['data'] ?? response['restaurants'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Restaurant.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 2. Fetch Selected Restaurant Metadata
  Future<Restaurant> getRestaurantDetails(int restaurantId) async {
    final response = await _apiClient.get('${ApiConfig.customerRestaurants}/$restaurantId');
    final data = response['data'] ?? response['restaurant'];
    return Restaurant.fromJson(data as Map<String, dynamic>);
  }

  // 3. Fetch Categories for a specific Restaurant
  Future<List<MenuCategory>> getRestaurantCategories(int restaurantId) async {
    final response = await _apiClient.get('${ApiConfig.customerRestaurants}/$restaurantId/categories');
    final data = response['data'] ?? response['categories'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuCategory.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 4. Fetch Menu Items for a specific Restaurant (with optional category and search parameters)
  Future<List<MenuItem>> getRestaurantMenu(
    int restaurantId, {
    String? category,
    String? search,
    String? vegType,
  }) async {
    final queryParams = {
      if (category != null && category != 'All') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
      if (vegType != null && vegType != 'All') 'veg_type': vegType,
    };
    final response = await _apiClient.get(
      '${ApiConfig.customerRestaurants}/$restaurantId/menu',
      queryParameters: queryParams,
    );
    final data = response['data'] ?? response['menu_items'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 5. Fetch Subscription Plans for a specific Restaurant
  Future<List<SubscriptionPlan>> getRestaurantPlans(int restaurantId) async {
    final response = await _apiClient.get('${ApiConfig.customerRestaurants}/$restaurantId/subscription-plans');
    final data = response['data'] ?? response['plans'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 6. Submit Item to backend Cart
  Future<dynamic> postCartItem(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiConfig.cartItems, body: data);
  }

  // 7. Place Order/Checkout
  Future<Order> createOrder(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConfig.customerOrders, body: data);
    final resData = response['data'] ?? response['order'];
    return Order.fromJson(resData as Map<String, dynamic>);
  }

  // 8. Fetch Order History
  Future<List<Order>> getOrders() async {
    final response = await _apiClient.get(ApiConfig.customerOrders);
    final data = response['data'] ?? response['orders'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 9. Fetch Order Details & Tracking Status Timeline
  Future<Map<String, dynamic>> getOrderTracking(int orderId) async {
    final response = await _apiClient.get('${ApiConfig.customerOrders}/$orderId/tracking');
    return response as Map<String, dynamic>;
  }
}
