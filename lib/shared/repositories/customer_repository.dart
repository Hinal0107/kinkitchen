import 'package:kinkitchen/app/constants/api_constants.dart';
import 'package:kinkitchen/core/network/api_client.dart';
import 'package:kinkitchen/shared/models/restaurant.dart';
import 'package:kinkitchen/shared/models/menu_category.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';
import 'package:kinkitchen/shared/models/subscription_plan.dart';
import 'package:kinkitchen/shared/models/order.dart';

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

  List<dynamic> _extractList(dynamic response, [String? key]) {
    if (response == null) return [];
    if (response is List) return response;
    if (response is Map) {
      // 1. Check 'data' field
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map) {
          if (data.containsKey('id') || data.containsKey('name')) {
            return [data];
          }
          if (key != null && data.containsKey(key) && data[key] is List) {
            return data[key] as List;
          }
          for (final value in data.values) {
            if (value is List) return value;
          }
        }
      }
      // 2. Direct specified key check
      if (key != null && response.containsKey(key)) {
        final val = response[key];
        if (val is List) return val;
        if (val is Map && (val.containsKey('id') || val.containsKey('name'))) {
          return [val];
        }
      }
      // 3. Fallback scan for common array keys
      for (final k in ['daily_meals', 'meals', 'today_meals', 'tomorrow_meals', 'addons', 'add_ons', 'menu_items', 'items', 'categories', 'plans', 'restaurants']) {
        if (response.containsKey(k)) {
          final val = response[k];
          if (val is List) return val;
          if (val is Map && (val.containsKey('id') || val.containsKey('name'))) {
            return [val];
          }
        }
      }
      // 4. Any list at root level
      for (final value in response.values) {
        if (value is List) return value;
      }
    }
    return [];
  }

  // Fetch All Daily Meals for a Restaurant from GET /restaurants/{id}/daily-meals
  Future<List<MenuItem>> getAllDailyMeals(int restaurantId) async {
    // 1. Try GET /restaurants/{id}/daily-meals
    try {
      final response = await _apiClient.get(ApiConfig.dailyMeals(restaurantId));
      final list = _extractList(response, 'daily_meals');
      if (list.isNotEmpty) {
        return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // 2. Try GET /daily-meals
    try {
      final response = await _apiClient.get('/daily-meals');
      final list = _extractList(response, 'daily_meals');
      if (list.isNotEmpty) {
        return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // 3. Try GET /restaurant/daily-meals
    try {
      final response = await _apiClient.get(ApiConfig.restaurantDailyMeals);
      final list = _extractList(response, 'daily_meals');
      if (list.isNotEmpty) {
        return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return [];
  }

  // 6. Get Restaurant Addons
  Future<List<MenuItem>> getRestaurantAddons(int restaurantId) async {
    final Map<int, MenuItem> map = {};

    // 1. Fetch strictly from GET /restaurants/{id}/addons database table
    try {
      final response = await _apiClient.get(ApiConfig.restaurantAddons(restaurantId));
      final list = _extractList(response, 'addons');
      for (final json in list) {
        if (json is Map<String, dynamic>) {
          final item = MenuItem.fromJson(json);
          map[item.id] = item;
        }
      }
    } catch (_) {}

    // 2. Check GET /restaurants/{id}/daily-meals strictly for items explicitly marked as ADDON
    try {
      final allDaily = await getAllDailyMeals(restaurantId);
      for (final item in allDaily) {
        if (item.isAddon || item.mealType?.toUpperCase() == 'ADDON') {
          map[item.id] = item;
        }
      }
    } catch (_) {}

    return map.values.toList();
  }

  // 7. Get Restaurant Taxes
  Future<Map<String, dynamic>> getRestaurantTaxes(int restaurantId) async {
    try {
      final response = await _apiClient.get(ApiConfig.restaurantTaxes(restaurantId));
      return (response['data'] ?? response) as Map<String, dynamic>;
    } catch (_) {
      return {'tax_rate': 5.0};
    }
  }

  // 8. Get Today's Meal
  Future<List<MenuItem>> getTodayMeal(int restaurantId) async {
    final Map<int, MenuItem> map = {};
    final String todayDateStr = DateTime.now().toString().split(' ').first;

    // 1. Fetch from GET /restaurants/{id}/today-meal first
    try {
      final response = await _apiClient.get(ApiConfig.todayMeal(restaurantId));
      final list = _extractList(response, 'today_meals');
      for (final json in list) {
        if (json is Map<String, dynamic>) {
          final item = MenuItem.fromJson(json);
          map[item.id] = item;
        }
      }
    } catch (_) {}

    // 2. Fetch from GET /restaurants/{id}/daily-meals & filter TODAY or today's date
    if (map.isEmpty) {
      final allDaily = await getAllDailyMeals(restaurantId);
      for (final item in allDaily) {
        final mType = item.mealType?.toUpperCase();
        final sDate = item.scheduleDate;
        if (mType == 'TODAY' || sDate == todayDateStr || (mType == null || mType.isEmpty)) {
          if (mType != 'TOMORROW' && mType != 'ADDON') {
            map[item.id] = item;
          }
        }
      }

      // Fallback: If map is still empty but allDaily has non-addon items, return them
      if (map.isEmpty && allDaily.isNotEmpty) {
        final nonAddons = allDaily.where((i) => !i.isAddon && i.mealType?.toUpperCase() != 'ADDON').toList();
        return nonAddons.isNotEmpty ? nonAddons : allDaily;
      }
    }

    return map.values.toList();
  }

  // 9. Get Tomorrow's Meal
  Future<List<MenuItem>> getTomorrowMeal(int restaurantId) async {
    final Map<int, MenuItem> map = {};
    final String tomorrowDateStr = DateTime.now().add(const Duration(days: 1)).toString().split(' ').first;

    // 1. Fetch from GET /restaurants/{id}/tomorrow-meal first
    try {
      final response = await _apiClient.get(ApiConfig.tomorrowMeal(restaurantId));
      final list = _extractList(response, 'tomorrow_meals');
      for (final json in list) {
        if (json is Map<String, dynamic>) {
          final item = MenuItem.fromJson(json);
          map[item.id] = item;
        }
      }
    } catch (_) {}

    // 2. Fetch from GET /restaurants/{id}/daily-meals & filter TOMORROW or tomorrow's date
    if (map.isEmpty) {
      final allDaily = await getAllDailyMeals(restaurantId);
      for (final item in allDaily) {
        final mType = item.mealType?.toUpperCase();
        final sDate = item.scheduleDate;
        if (mType == 'TOMORROW' || sDate == tomorrowDateStr) {
          map[item.id] = item;
        }
      }
    }

    return map.values.toList();
  }

  // 9b. Get Weekly Meal Plan
  Future<List<MenuItem>> getWeeklyMeal(int restaurantId) async {
    final Map<int, MenuItem> map = {};

    // 1. Fetch from GET /restaurants/{id}/daily-meals & filter WEEKLY
    final allDaily = await getAllDailyMeals(restaurantId);
    for (final item in allDaily) {
      final mType = item.mealType?.toUpperCase();
      if (mType == 'WEEKLY') {
        map[item.id] = item;
      }
    }

    // 2. Also fetch from GET /restaurants/{id}/weekly-meal
    try {
      final response = await _apiClient.get(ApiConfig.weeklyMeal(restaurantId));
      final list = _extractList(response, 'weekly_meals');
      for (final json in list) {
        if (json is Map<String, dynamic>) {
          final item = MenuItem.fromJson(json);
          map[item.id] = item;
        }
      }
    } catch (_) {}

    return map.values.toList();
  }

  // 10. Get Daily Meals by date (e.g. 2026-08-25)
  Future<List<MenuItem>> getDailyMeals(int restaurantId, String date) async {
    final response = await _apiClient.get(
      ApiConfig.dailyMeals(restaurantId),
      queryParameters: {'date': date},
    );
    final list = _extractList(response, 'daily_meals');
    return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 11. Get Subscription Plans for a Restaurant
  Future<List<SubscriptionPlan>> getRestaurantPlans(int restaurantId) async {
    final response = await _apiClient.get(ApiConfig.restaurantPlans(restaurantId));
    final list = _extractList(response, 'plans');
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

  Future<Order> confirmOrderReceived(int orderId) async {
    final ApiClient apiClient = ApiClient();
    final response = await apiClient.post('/orders/$orderId/confirm-received');
    final resData = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(resData as Map<String, dynamic>);
  }
}
