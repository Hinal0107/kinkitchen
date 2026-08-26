import 'dart:io';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/restaurant.dart';
import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../models/daily_meal_item.dart';
import '../models/subscription_plan.dart';
import '../models/order.dart';

class RestaurantRepository {
  final ApiClient _apiClient;

  RestaurantRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // --- 🏪 PROFILE ---
  Future<Restaurant> getProfile() async {
    final response = await _apiClient.get(ApiConfig.restaurantProfile);
    final data = response['data'] ?? response['restaurant'] ?? response;
    return Restaurant.fromJson(data as Map<String, dynamic>);
  }

  Future<Restaurant> updateProfile(Map<String, String> fields, {File? logo}) async {
    dynamic response;
    if (logo != null) {
      response = await _apiClient.multipart(
        'POST',
        ApiConfig.restaurantProfile,
        {
          '_method': 'PUT',
          ...fields,
        },
        fileKey: 'logo',
        file: logo,
      );
    } else {
      response = await _apiClient.put(
        ApiConfig.restaurantProfile,
        body: fields,
      );
    }
    final data = response['data'] ?? response['restaurant'] ?? response;
    return Restaurant.fromJson(data as Map<String, dynamic>);
  }

  // --- 📂 CATEGORIES ---
  Future<List<MenuCategory>> getCategories() async {
    final response = await _apiClient.get(ApiConfig.restaurantCategories);
    final data = response['data'] ?? response['categories'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuCategory.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<MenuCategory> createCategory(String name, String description, String status, {File? image}) async {
    dynamic response;
    final isActiveStr = (status.toUpperCase() == 'ACTIVE').toString();
    if (image != null) {
      response = await _apiClient.multipart(
        'POST',
        ApiConfig.restaurantCategories,
        {
          'name': name,
          'description': description,
          'status': status,
          'is_active': isActiveStr,
        },
        fileKey: 'image',
        file: image,
      );
    } else {
      response = await _apiClient.post(
        ApiConfig.restaurantCategories,
        body: {
          'name': name,
          'description': description,
          'status': status,
          'is_active': status.toUpperCase() == 'ACTIVE',
        },
      );
    }
    final data = response['data'] ?? response['category'] ?? response;
    return MenuCategory.fromJson(data as Map<String, dynamic>);
  }

  Future<MenuCategory> updateCategory(int id, String name, String description, String status, {File? image}) async {
    dynamic response;
    final isActiveStr = (status.toUpperCase() == 'ACTIVE').toString();
    if (image != null) {
      response = await _apiClient.multipart(
        'POST',
        '${ApiConfig.restaurantCategories}/$id',
        {
          '_method': 'PUT',
          'name': name,
          'description': description,
          'status': status,
          'is_active': isActiveStr,
        },
        fileKey: 'image',
        file: image,
      );
    } else {
      response = await _apiClient.put(
        '${ApiConfig.restaurantCategories}/$id',
        body: {
          'name': name,
          'description': description,
          'status': status,
          'is_active': status.toUpperCase() == 'ACTIVE',
        },
      );
    }
    final data = response['data'] ?? response['category'] ?? response;
    return MenuCategory.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantCategories}/$id');
  }

  // --- 🍛 MENU ITEMS ---
  Future<List<MenuItem>> getMenuItems({String? category, String? search, int limit = 50}) async {
    final queryParams = {
      if (category != null && category != 'All') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
      'limit': limit.toString(),
    };
    final response = await _apiClient.get(ApiConfig.restaurantMenuItems, queryParameters: queryParams);
    final data = response['data'] ?? response['menu_items'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<MenuItem> createMenuItem(Map<String, String> fields, {File? image}) async {
    dynamic response;
    if (image != null) {
      response = await _apiClient.multipart(
        'POST',
        ApiConfig.restaurantMenuItems,
        fields,
        fileKey: 'image',
        file: image,
      );
    } else {
      response = await _apiClient.post(
        ApiConfig.restaurantMenuItems,
        body: fields,
      );
    }
    final data = response['data'] ?? response['menu_item'] ?? response;
    return MenuItem.fromJson(data as Map<String, dynamic>);
  }

  Future<MenuItem> updateMenuItem(int id, Map<String, String> fields, {File? image}) async {
    dynamic response;
    if (image != null) {
      response = await _apiClient.multipart(
        'POST',
        '${ApiConfig.restaurantMenuItems}/$id',
        {
          '_method': 'PUT',
          ...fields,
        },
        fileKey: 'image',
        file: image,
      );
    } else {
      response = await _apiClient.put(
        '${ApiConfig.restaurantMenuItems}/$id',
        body: fields,
      );
    }
    final data = response['data'] ?? response['menu_item'] ?? response;
    return MenuItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteMenuItem(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantMenuItems}/$id');
  }

  // --- 📅 DAILY MEALS ---
  Future<List<DailyMealItem>> getDailyMeals() async {
    final response = await _apiClient.get(ApiConfig.restaurantDailyMeals);
    final data = response['data'] ?? response['daily_meals'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => DailyMealItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<DailyMealItem> createDailyMeal(Map<String, String> fields, {File? image}) async {
    dynamic response;
    if (image != null) {
      response = await _apiClient.multipart(
        'POST',
        ApiConfig.restaurantDailyMeals,
        fields,
        fileKey: 'image',
        file: image,
      );
    } else {
      response = await _apiClient.post(
        ApiConfig.restaurantDailyMeals,
        body: fields,
      );
    }
    final data = response['data'] ?? response['daily_meal'] ?? response;
    return DailyMealItem.fromJson(data as Map<String, dynamic>);
  }

  Future<DailyMealItem> updateDailyMeal(int id, Map<String, String> fields, {File? image}) async {
    dynamic response;
    if (image != null) {
      response = await _apiClient.multipart(
        'POST',
        '${ApiConfig.restaurantDailyMeals}/$id',
        {
          '_method': 'PUT',
          ...fields,
        },
        fileKey: 'image',
        file: image,
      );
    } else {
      response = await _apiClient.put(
        '${ApiConfig.restaurantDailyMeals}/$id',
        body: fields,
      );
    }
    final data = response['data'] ?? response['daily_meal'] ?? response;
    return DailyMealItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteDailyMeal(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantDailyMeals}/$id');
  }

  // --- 📋 SUBSCRIPTION PLANS ---
  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await _apiClient.get(ApiConfig.restaurantSubscriptionPlans);
    final data = response['data'] ?? response['plans'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<SubscriptionPlan> createPlan(Map<String, dynamic> body) async {
    final response = await _apiClient.post(ApiConfig.restaurantSubscriptionPlans, body: body);
    final data = response['data'] ?? response['plan'] ?? response;
    return SubscriptionPlan.fromJson(data as Map<String, dynamic>);
  }

  Future<SubscriptionPlan> updatePlan(int id, Map<String, dynamic> body) async {
    final response = await _apiClient.put('${ApiConfig.restaurantSubscriptionPlans}/$id', body: body);
    final data = response['data'] ?? response['plan'] ?? response;
    return SubscriptionPlan.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deletePlan(int id) async {
    await _apiClient.delete('${ApiConfig.restaurantSubscriptionPlans}/$id');
  }

  // --- 🚀 ORDERS ---
  Future<List<Order>> getOrders({String? status, int limit = 50}) async {
    final queryParams = {
      if (status != null && status.isNotEmpty) 'status': status,
      'limit': limit.toString(),
    };
    final response = await _apiClient.get(ApiConfig.restaurantOrders, queryParameters: queryParams);
    final data = response['data'] ?? response['orders'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Order> updateOrderStatus(int id, String status) async {
    final response = await _apiClient.post('${ApiConfig.restaurantOrders}/$id/$status');
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }
}
