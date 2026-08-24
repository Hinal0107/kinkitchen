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
    return Restaurant.fromJson(response['restaurant']);
  }

  Future<Restaurant> updateProfile(Map<String, String> fields, {File? logo}) async {
    final response = await _apiClient.multipart(
      'POST', // Often Laravel uses POST with _method=PUT or straight POST for multipart
      ApiConfig.restaurantProfile,
      fields,
      fileKey: logo != null ? 'logo' : null,
      file: logo,
    );
    return Restaurant.fromJson(response['restaurant']);
  }

  // 2. Menu Category Actions
  Future<List<MenuCategory>> getCategories() async {
    final response = await _apiClient.get(ApiConfig.restaurantCategories);
    final List<dynamic> list = response['categories'] ?? [];
    return list.map((json) => MenuCategory.fromJson(json)).toList();
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
    return MenuCategory.fromJson(response['category']);
  }

  Future<MenuCategory> updateCategory(int id, String name, String description, String status, {File? image}) async {
    final response = await _apiClient.multipart(
      'POST',
      '${ApiConfig.restaurantCategories}/$id',
      {
        '_method': 'PUT', // Laravel method spoofing for multipart PUT
        'name': name,
        'description': description,
        'status': status,
      },
      fileKey: image != null ? 'image' : null,
      file: image,
    );
    return MenuCategory.fromJson(response['category']);
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
    final List<dynamic> list = response['menu_items'] ?? [];
    return list.map((json) => MenuItem.fromJson(json)).toList();
  }

  Future<MenuItem> createMenuItem(Map<String, String> fields, {File? image}) async {
    final response = await _apiClient.multipart(
      'POST',
      ApiConfig.restaurantMenuItems,
      fields,
      fileKey: image != null ? 'image' : null,
      file: image,
    );
    return MenuItem.fromJson(response['menu_item']);
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
    return MenuItem.fromJson(response['menu_item']);
  }

  Future<void> deleteMenuItem(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantMenuItems}/$id');
  }

  // 4. Subscription Plan Actions
  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await _apiClient.get(ApiConfig.restaurantPlans);
    final List<dynamic> list = response['plans'] ?? [];
    return list.map((json) => SubscriptionPlan.fromJson(json)).toList();
  }

  Future<SubscriptionPlan> createPlan(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConfig.restaurantPlans, body: data);
    return SubscriptionPlan.fromJson(response['plan']);
  }

  Future<SubscriptionPlan> updatePlan(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('${ApiConfig.restaurantPlans}/$id', body: data);
    return SubscriptionPlan.fromJson(response['plan']);
  }

  Future<void> deletePlan(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantPlans}/$id');
  }

  // 5. Orders Actions
  Future<List<Order>> getOrders() async {
    final response = await _apiClient.get(ApiConfig.restaurantOrders);
    final List<dynamic> list = response['orders'] ?? [];
    return list.map((json) => Order.fromJson(json)).toList();
  }

  Future<Order> updateOrderStatus(int id, String status) async {
    final response = await _apiClient.put('${ApiConfig.restaurantOrders}/$id/status', body: {'status': status});
    return Order.fromJson(response['order']);
  }
}
