import 'dart:io';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/restaurant.dart';
import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../models/subscription_plan.dart';
import '../models/order.dart';

class RestaurantRepository {
  final ApiClient _apiClient;

  RestaurantRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // 1. Profile Actions
  Future<Restaurant> getProfile() async {
    final response = await _apiClient.get(ApiConfig.restaurantProfile);
    final data = response['data'] ?? response['restaurant'];
    return Restaurant.fromJson(data as Map<String, dynamic>);
  }

  Future<Restaurant> updateProfile(Map<String, String> fields, {File? logo}) async {
    final response = await _apiClient.multipart(
      'POST',
      ApiConfig.restaurantProfile,
      fields,
      fileKey: logo != null ? 'logo' : null,
      file: logo,
    );
    final data = response['data'] ?? response['restaurant'];
    return Restaurant.fromJson(data as Map<String, dynamic>);
  }

  // 2. Menu Category Actions
  Future<List<MenuCategory>> getCategories() async {
    final response = await _apiClient.get(ApiConfig.restaurantCategories);
    final data = response['data'] ?? response['categories'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuCategory.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<MenuCategory> createCategory(String name, String description, String status, {File? image}) async {
    final response = await _apiClient.multipart(
      'POST',
      ApiConfig.restaurantCategories,
      {
        'name': name,
        'description': description,
        'status': status,
      },
      fileKey: image != null ? 'image' : null,
      file: image,
    );
    final data = response['data'] ?? response['category'];
    return MenuCategory.fromJson(data as Map<String, dynamic>);
  }

  Future<MenuCategory> updateCategory(int id, String name, String description, String status, {File? image}) async {
    final response = await _apiClient.multipart(
      'POST',
      '${ApiConfig.restaurantCategories}/$id',
      {
        '_method': 'PUT',
        'name': name,
        'description': description,
        'status': status,
      },
      fileKey: image != null ? 'image' : null,
      file: image,
    );
    final data = response['data'] ?? response['category'];
    return MenuCategory.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantCategories}/$id');
  }

  // 3. Menu Item Actions
  Future<List<MenuItem>> getMenuItems({String? category, String? search}) async {
    final queryParams = {
      if (category != null && category != 'All') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await _apiClient.get(ApiConfig.restaurantMenuItems, queryParameters: queryParams);
    final data = response['data'] ?? response['menu_items'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<MenuItem> createMenuItem(Map<String, String> fields, {File? image}) async {
    final response = await _apiClient.multipart(
      'POST',
      ApiConfig.restaurantMenuItems,
      fields,
      fileKey: image != null ? 'image' : null,
      file: image,
    );
    final data = response['data'] ?? response['menu_item'];
    return MenuItem.fromJson(data as Map<String, dynamic>);
  }

  Future<MenuItem> updateMenuItem(int id, Map<String, String> fields, {File? image}) async {
    final response = await _apiClient.multipart(
      'POST',
      '${ApiConfig.restaurantMenuItems}/$id',
      {
        '_method': 'PUT',
        ...fields,
      },
      fileKey: image != null ? 'image' : null,
      file: image,
    );
    final data = response['data'] ?? response['menu_item'];
    return MenuItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteMenuItem(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantMenuItems}/$id');
  }

  // 4. Subscription Plan Actions
  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await _apiClient.get(ApiConfig.restaurantPlans);
    final data = response['data'] ?? response['plans'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<SubscriptionPlan> createPlan(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConfig.restaurantPlans, body: data);
    final resData = response['data'] ?? response['plan'];
    return SubscriptionPlan.fromJson(resData as Map<String, dynamic>);
  }

  Future<SubscriptionPlan> updatePlan(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('${ApiConfig.restaurantPlans}/$id', body: data);
    final resData = response['data'] ?? response['plan'];
    return SubscriptionPlan.fromJson(resData as Map<String, dynamic>);
  }

  Future<void> deletePlan(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantPlans}/$id');
  }

  // 5. Orders Actions
  Future<List<Order>> getOrders() async {
    final response = await _apiClient.get(ApiConfig.restaurantOrders);
    final data = response['data'] ?? response['orders'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Order> updateOrderStatus(int id, String status) async {
    final response = await _apiClient.put('${ApiConfig.restaurantOrders}/$id/status', body: {'status': status});
    final data = response['data'] ?? response['order'];
    return Order.fromJson(data as Map<String, dynamic>);
  }
}
