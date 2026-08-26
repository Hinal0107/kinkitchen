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

  // 1. Browse Active Restaurants (Filtered by nearby area/city/pincode/coords and status)
  Future<List<Restaurant>> getRestaurants({
    String? city,
    String? pincode,
    double? latitude,
    double? longitude,
    String status = 'ACTIVE',
  }) async {
    final queryParams = {
      if (city != null && city.isNotEmpty) 'city': city,
      if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      if (status.isNotEmpty) 'status': status,
    };
    final response = await _apiClient.get(
      ApiConfig.restaurants,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response['data'] ?? response['restaurants'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Restaurant.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 1b. Select & Persist Customer's Selected Restaurant
  Future<void> setSelectedRestaurant(int restaurantId) async {
    await _apiClient.post(
      '/customer/selected-restaurant',
      body: {'restaurant_id': restaurantId},
    );
  }

  // 2. Get Restaurant Details
  Future<Restaurant> getRestaurantDetails(int restaurantId) async {
    final response = await _apiClient.get('${ApiConfig.restaurants}/$restaurantId');
    final data = response['data'] ?? response['restaurant'];
    return Restaurant.fromJson(data as Map<String, dynamic>);
  }

  // 3. Get Restaurant Categories
  Future<List<MenuCategory>> getRestaurantCategories(int restaurantId) async {
    final response = await _apiClient.get('${ApiConfig.restaurants}/$restaurantId/categories');
    final data = response['data'] ?? response['categories'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuCategory.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 4. Get Restaurant Menu Items
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
      '${ApiConfig.restaurants}/$restaurantId/menu',
      queryParameters: queryParams,
    );
    final data = response['data'] ?? response['menu_items'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 5. Get Menu Item Details
  Future<MenuItem> getMenuItemDetails(int menuItemId) async {
    final response = await _apiClient.get('${ApiConfig.menuItemDetails}/$menuItemId');
    final data = response['data'] ?? response['menu_item'];
    return MenuItem.fromJson(data as Map<String, dynamic>);
  }

  // 6. Get Restaurant Addons
  Future<List<MenuItem>> getRestaurantAddons(int restaurantId) async {
    final response = await _apiClient.get(ApiConfig.restaurantAddons(restaurantId));
    final data = response['data'] ?? response['addons'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 7. Get Restaurant Taxes
  Future<Map<String, dynamic>> getRestaurantTaxes(int restaurantId) async {
    final response = await _apiClient.get(ApiConfig.restaurantTaxes(restaurantId));
    return (response['data'] ?? response) as Map<String, dynamic>;
  }

  // 8. Get Today's Meal
  Future<List<MenuItem>> getTodayMeal(int restaurantId) async {
    final response = await _apiClient.get(ApiConfig.todayMeal(restaurantId));
    final data = response['data'] ?? response['meals'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 9. Get Tomorrow's Meal
  Future<List<MenuItem>> getTomorrowMeal(int restaurantId) async {
    final response = await _apiClient.get(ApiConfig.tomorrowMeal(restaurantId));
    final data = response['data'] ?? response['meals'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 10. Get Daily Meals by date (e.g. 2026-08-25)
  Future<List<MenuItem>> getDailyMeals(int restaurantId, String date) async {
    final response = await _apiClient.get(
      ApiConfig.dailyMeals(restaurantId),
      queryParameters: {'date': date},
    );
    final data = response['data'] ?? response['meals'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 11. Get Subscription Plans for a Restaurant
  Future<List<SubscriptionPlan>> getRestaurantPlans(int restaurantId) async {
    final response = await _apiClient.get(ApiConfig.restaurantPlans(restaurantId));
    final data = response['data'] ?? response['plans'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>)).toList();
  }
}

extension CustomerRepositoryOrders on CustomerRepository {
  Future<Order> createOrder(Map<String, dynamic> data) async {
    final ApiClient apiClient = ApiClient();
    final response = await apiClient.post(ApiConfig.orders, body: data);
    final resData = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(resData as Map<String, dynamic>);
  }

  Future<List<Order>> getOrders() async {
    final ApiClient apiClient = ApiClient();
    final response = await apiClient.get(ApiConfig.orders);
    final data = response['data'] ?? response['orders'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
  }
}
