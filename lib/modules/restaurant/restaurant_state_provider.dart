import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kinkitchen/shared/repositories/restaurant_repository.dart';
import 'package:kinkitchen/shared/repositories/notification_repository.dart';
import 'package:kinkitchen/shared/models/restaurant.dart';
import 'package:kinkitchen/shared/models/menu_category.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';
import 'package:kinkitchen/shared/models/daily_meal_item.dart';
import 'package:kinkitchen/shared/models/subscription_plan.dart';
import 'package:kinkitchen/shared/models/order.dart';
import 'package:kinkitchen/shared/models/notification_item.dart';

class RestaurantStateProvider extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();

  // Notification State
  List<NotificationItem> notifications = [];
  int unreadNotificationCount = 0;

  // General Loading & Error States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Models fetched from API
  Restaurant? profile;
  List<MenuCategory> categories = [];
  List<MenuItem> menuItems = [];
  List<DailyMealItem> dailyMeals = [];
  List<SubscriptionPlan> subscriptionPlans = [];
  List<Order> orders = [];

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  // --- DATE HELPERS ---

  String get _todayDmy {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String get _todayYmd {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String get _tomorrowDmy {
    final tom = DateTime.now().add(const Duration(days: 1));
    return '${tom.day.toString().padLeft(2, '0')}/${tom.month.toString().padLeft(2, '0')}/${tom.year}';
  }

  // --- COMPATIBLE GETTERS ---

  int get totalItemsCount => menuItems.length;
  int get activeItemsCount => menuItems.where((i) => i.availability).length;
  int get categoriesCount => categories.length;

  MenuCategory? get addonsCategory {
    try {
      return categories.firstWhere(
        (c) => c.name.toLowerCase().contains('add-on') || c.name.toLowerCase().contains('addon'),
      );
    } catch (_) {
      return null;
    }
  }

  int get addonsCount {
    final cat = addonsCategory;
    if (cat == null) return 0;
    return menuItems.where((item) => item.categoryId == cat.id).length;
  }

  /// All add-on items (shared between today & tomorrow)
  List<Map<String, dynamic>> get addons {
    final cat = addonsCategory;
    if (cat == null) return [];
    return menuItems.where((item) => item.categoryId == cat.id).map((item) => {
      'id': item.id,
      'title': item.name,
      'name': item.name,
      'description': item.description,
      'price': item.price,
      'isVeg': item.vegType == 'VEG' || item.vegType == 'JAIN',
      'isActive': item.availability,
      'isActiveToday': item.availability,
      'isActiveTomorrow': item.availability,
      'availableQty': item.availability ? 50 : 0,
      'totalQty': 50,
      'image': item.imageUrl,
      'imageUrl': item.imageUrl,
    }).toList();
  }

  List<Map<String, dynamic>> get todayAddons => addons;
  List<Map<String, dynamic>> get tomorrowAddons => addons;

  /// Menu items shown in the Menu tab (stored in menu_items table)
  List<Map<String, dynamic>> get menuItemsMap {
    final addonCat = addonsCategory;
    return menuItems.where((item) {
      if (addonCat != null && item.categoryId == addonCat.id) return false;
      return true;
    }).map((item) {
      final categoryName = categories.firstWhere(
        (c) => c.id == item.categoryId,
        orElse: () => MenuCategory(id: 0, restaurantId: 0, name: 'General', description: '', status: 'ACTIVE'),
      ).name;
      return {
        'id': item.id,
        'title': item.name,
        'price': item.price,
        'isVeg': item.vegType == 'VEG' || item.vegType == 'JAIN',
        'isActive': item.availability,
        'category': categoryName,
        'description': item.description,
        'image': item.imageUrl,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get plans {
    return subscriptionPlans.map((p) => {
      'id': p.id,
      'title': p.title,
      'price': p.price,
      'duration': p.duration,
      'meals': '${p.mealsCount} Meals',
      'mealType': p.mealType,
      'taxesAndDisc': p.taxesAndDisc,
      'isPopular': p.isPopular,
      'isActive': p.status == 'ACTIVE' || p.status == 'active',
      'period': p.duration == 'Weekly' ? '/week' : '/month',
    }).toList();
  }

  /// Today's meals fetched from daily_meals table
  List<Map<String, dynamic>> get todayMeals {
    final now = DateTime.now();
    final todayYmd = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todayDmy = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return dailyMeals.where((meal) {
      final mType = meal.mealType.trim().toUpperCase();
      if (mType == 'TODAY') return true;
      if (mType == 'TOMORROW' || mType == 'WEEKLY') return false;
      return meal.date == todayYmd || meal.date == todayDmy || meal.date.startsWith(todayYmd);
    }).map((meal) => {
      'id': meal.id,
      'title': meal.name,
      'name': meal.name,
      'description': meal.description,
      'price': meal.price,
      'discount_price': meal.discountPrice,
      'discountPrice': meal.discountPrice,
      'gst': '5%',
      'availableQty': meal.availability ? 50 : 0,
      'totalQty': 50,
      'isActive': meal.availability,
      'createdAt': 'Today',
      'isVeg': meal.vegType == 'VEG' || meal.vegType == 'JAIN',
      'veg_type': meal.vegType,
      'meal_type': meal.mealType,
      'date': meal.date,
      'image': meal.image,
      'imageUrl': meal.image,
      'addons': meal.addons,
    }).toList();
  }

  /// Tomorrow's meals fetched from daily_meals table
  List<Map<String, dynamic>> get tomorrowMeals {
    final tom = DateTime.now().add(const Duration(days: 1));
    final tomYmd = '${tom.year}-${tom.month.toString().padLeft(2, '0')}-${tom.day.toString().padLeft(2, '0')}';
    final tomDmy = '${tom.day.toString().padLeft(2, '0')}/${tom.month.toString().padLeft(2, '0')}/${tom.year}';

    return dailyMeals.where((meal) {
      final mType = meal.mealType.trim().toUpperCase();
      if (mType == 'TOMORROW') return true;
      if (mType == 'TODAY' || mType == 'WEEKLY') return false;
      return meal.date == tomYmd || meal.date == tomDmy || meal.date.startsWith(tomYmd);
    }).map((meal) => {
      'id': meal.id,
      'title': meal.name,
      'name': meal.name,
      'description': meal.description,
      'price': meal.price,
      'discount_price': meal.discountPrice,
      'discountPrice': meal.discountPrice,
      'availableQty': meal.availability ? 50 : 0,
      'totalQty': 50,
      'isActive': meal.availability,
      'isVeg': meal.vegType == 'VEG' || meal.vegType == 'JAIN',
      'veg_type': meal.vegType,
      'meal_type': meal.mealType,
      'date': meal.date,
      'image': meal.image,
      'imageUrl': meal.image,
      'addons': meal.addons,
    }).toList();
  }

  // --- API FETCH CALLS ---

  Future<void> fetchProfile() async {
    _setLoading(true);
    try {
      profile = await _restaurantRepository.getProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      categories = await _restaurantRepository.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchMenuItems({String? category, String? search}) async {
    _setLoading(true);
    try {
      menuItems = await _restaurantRepository.getMenuItems(category: category, search: search);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchDailyMeals() async {
    _setLoading(true);
    try {
      dailyMeals = await _restaurantRepository.getDailyMeals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchPlans() async {
    _setLoading(true);
    try {
      subscriptionPlans = await _restaurantRepository.getPlans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchOrders() async {
    _setLoading(true);
    try {
      orders = await _restaurantRepository.getOrders();
      await fetchNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Fetch Notifications & Unread Count for Restaurant
  Future<void> fetchNotifications() async {
    try {
      notifications = await _notificationRepository.getNotifications();
      unreadNotificationCount = await _notificationRepository.getUnreadCount();
      notifyListeners();
    } catch (_) {
      unreadNotificationCount = notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
    } catch (_) {}
    notifications = notifications.map((n) {
      if (n.id == notificationId) {
        return NotificationItem(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    unreadNotificationCount = notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
    } catch (_) {}
    notifications = notifications.map((n) {
      return NotificationItem(
        id: n.id,
        userId: n.userId,
        title: n.title,
        body: n.body,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();
    unreadNotificationCount = 0;
    notifyListeners();
  }

  // --- API MUTATION ACTIONS ---

  Future<void> updateProfile(Map<String, String> fields, {File? logo}) async {
    _setLoading(true);
    try {
      profile = await _restaurantRepository.updateProfile(fields, logo: logo);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> createCategory(String name, String description, String status, {File? image}) async {
    _setLoading(true);
    try {
      await _restaurantRepository.createCategory(name, description, status, image: image);
      categories = await _restaurantRepository.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateCategory(int id, String name, String description, String status, {File? image}) async {
    _setLoading(true);
    try {
      await _restaurantRepository.updateCategory(id, name, description, status, image: image);
      categories = await _restaurantRepository.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    _setLoading(true);
    try {
      await _restaurantRepository.deleteCategory(id);
      categories = await _restaurantRepository.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // --- MENU ITEMS (GENERAL MENU) ---

  Future<void> addMenuItem(Map<String, String> fields, {File? image}) async {
    _setLoading(true);
    try {
      final sanitizedFields = Map<String, String>.from(fields);
      sanitizedFields['status'] = 'ACTIVE';
      await _restaurantRepository.createMenuItem(sanitizedFields, image: image);
      menuItems = await _restaurantRepository.getMenuItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateMenuItem(int id, Map<String, String> fields, {File? image}) async {
    _setLoading(true);
    try {
      final sanitizedFields = Map<String, String>.from(fields);
      await _restaurantRepository.updateMenuItem(id, sanitizedFields, image: image);
      menuItems = await _restaurantRepository.getMenuItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> toggleMenuItemActive(MenuItem item) async {
    _setLoading(true);
    try {
      final fields = {
        'category_id': item.categoryId.toString(),
        'restaurant_id': item.restaurantId.toString(),
        'name': item.name,
        'price': item.price.toString(),
        'availability': (!item.availability).toString(),
        'status': 'ACTIVE',
      };
      await _restaurantRepository.updateMenuItem(item.id, fields);
      menuItems = await _restaurantRepository.getMenuItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteMenuItem(int id) async {
    _setLoading(true);
    try {
      await _restaurantRepository.deleteMenuItem(id);
      menuItems = await _restaurantRepository.getMenuItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // --- DAILY MEALS (TODAY, TOMORROW, WEEKLY - STORED IN daily_meals TABLE) ---

  Future<void> addDailyMeal(Map<String, String> fields, {File? image}) async {
    _setLoading(true);
    try {
      final sanitizedFields = Map<String, String>.from(fields);
      sanitizedFields['status'] = 'ACTIVE';
      await _restaurantRepository.createDailyMeal(sanitizedFields, image: image);
      dailyMeals = await _restaurantRepository.getDailyMeals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateDailyMealItem(int id, String newTitle, double price, bool isVeg) async {
    _setLoading(true);
    try {
      final item = dailyMeals.firstWhere((i) => i.id == id);
      await _restaurantRepository.updateDailyMeal(id, {
        'name': newTitle,
        'description': item.description,
        'price': price.toString(),
        'veg_type': isVeg ? 'VEG' : 'NON_VEG',
        'availability': item.availability ? '1' : '0',
        'status': 'ACTIVE',
        'meal_type': item.mealType,
        'date': item.date,
      });
      dailyMeals = await _restaurantRepository.getDailyMeals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> deleteDailyMealById(int id) async {
    _setLoading(true);
    try {
      await _restaurantRepository.deleteDailyMeal(id);
      dailyMeals = await _restaurantRepository.getDailyMeals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper for category creation
  Future<int> _getOrCreateCategoryId(String name, String description) async {
    try {
      categories = await _restaurantRepository.getCategories();
      final match = categories.where(
        (c) => c.name.toLowerCase().contains('add-on') || c.name.toLowerCase().contains('addon') || c.name.toLowerCase() == name.toLowerCase(),
      );
      if (match.isNotEmpty) return match.first.id;

      await createCategory(name, description, 'ACTIVE');
      categories = await _restaurantRepository.getCategories();
      final newMatch = categories.where(
        (c) => c.name.toLowerCase().contains('add-on') || c.name.toLowerCase().contains('addon') || c.name.toLowerCase() == name.toLowerCase(),
      );
      return newMatch.isNotEmpty ? newMatch.first.id : (categories.isNotEmpty ? categories.first.id : 1);
    } catch (_) {
      return categories.isNotEmpty ? categories.first.id : 1;
    }
  }

  // --- TODAY MEAL ACTIONS ---

  Future<void> addTodayMeal(String title, double price, int qty, bool isVeg) async {
    await addDailyMeal({
      'date': _todayDmy,
      'name': title,
      'description': "Today's special meal.",
      'price': price.toString(),
      'veg_type': isVeg ? 'VEG' : 'NON_VEG',
      'meal_type': 'TODAY',
      'availability': '1',
      'status': 'ACTIVE',
    });
  }

  Future<void> updateDailyMeal(int id, Map<String, String> fields, {File? image}) async {
    _setLoading(true);
    try {
      await _restaurantRepository.updateDailyMeal(id, fields, image: image);
      dailyMeals = await _restaurantRepository.getDailyMeals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> toggleDailyMealActive(int id) async {
    _setLoading(true);
    try {
      final item = dailyMeals.firstWhere((i) => i.id == id);
      await _restaurantRepository.updateDailyMeal(id, {
        'name': item.name,
        'description': item.description,
        'price': item.price.toString(),
        'veg_type': item.vegType,
        'availability': (!item.availability) ? '1' : '0',
        'status': 'ACTIVE',
        'meal_type': item.mealType,
        'date': item.date,
      });
      dailyMeals = await _restaurantRepository.getDailyMeals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> toggleTodayMealActive(String title) async {
    final index = dailyMeals.indexWhere((item) => item.name == title);
    if (index >= 0) await toggleDailyMealActive(dailyMeals[index].id);
  }

  Future<void> updateTodayMealItem(int id, String newTitle, double price, bool isVeg) async {
    await updateDailyMealItem(id, newTitle, price, isVeg);
  }

  Future<void> deleteTodayMeal(String title) async {
    final index = dailyMeals.indexWhere((item) => item.name == title);
    if (index >= 0) await deleteDailyMealById(dailyMeals[index].id);
  }

  // --- TOMORROW MEAL ACTIONS ---

  Future<void> addTomorrowMealNew(String title, double price, int qty, bool isVeg) async {
    await addDailyMeal({
      'date': _tomorrowDmy,
      'name': title,
      'description': "Tomorrow's pre-planned meal.",
      'price': price.toString(),
      'veg_type': isVeg ? 'VEG' : 'NON_VEG',
      'meal_type': 'TOMORROW',
      'availability': '1',
      'status': 'ACTIVE',
    });
  }

  Future<void> updateTomorrowMealItem(int id, String newTitle, double price, bool isVeg) async {
    await updateDailyMealItem(id, newTitle, price, isVeg);
  }

  Future<void> toggleTomorrowMealActive(String title) async {
    final index = dailyMeals.indexWhere((item) => item.name == title);
    if (index >= 0) await toggleDailyMealActive(dailyMeals[index].id);
  }

  Future<void> deleteTomorrowMeal(String title) async {
    final index = dailyMeals.indexWhere((item) => item.name == title);
    if (index >= 0) await deleteDailyMealById(dailyMeals[index].id);
  }

  // --- ADDON MANAGEMENT ACTIONS ---

  Future<void> addAddon(
    String title,
    double price,
    int qty,
    bool isVeg, {
    String description = '',
    bool isAvailable = true,
    File? image,
  }) async {
    _setLoading(true);
    try {
      final categoryId = await _getOrCreateCategoryId('Add-ons', 'Extra side dishes and beverages');
      await addMenuItem({
        'category_id': categoryId.toString(),
        'restaurant_id': profile?.id.toString() ?? '1',
        'name': title,
        'description': description.isNotEmpty ? description : 'Add-on item',
        'price': price.toString(),
        'veg_type': isVeg ? 'VEG' : 'NON_VEG',
        'availability': isAvailable ? '1' : '0',
        'is_addon': '1',
        'status': 'ACTIVE',
      }, image: image);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateAddon(
    int id,
    String newTitle,
    double price,
    bool isVeg, {
    String description = '',
    bool isAvailable = true,
    File? image,
  }) async {
    _setLoading(true);
    try {
      final item = menuItems.firstWhere((i) => i.id == id);
      await _restaurantRepository.updateMenuItem(id, {
        'category_id': item.categoryId.toString(),
        'restaurant_id': item.restaurantId.toString(),
        'name': newTitle,
        'description': description.isNotEmpty ? description : item.description,
        'price': price.toString(),
        'veg_type': isVeg ? 'VEG' : 'NON_VEG',
        'availability': isAvailable ? '1' : '0',
        'is_addon': '1',
        'status': 'ACTIVE',
      }, image: image);
      menuItems = await _restaurantRepository.getMenuItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> toggleAddonActive(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) await toggleMenuItemActive(menuItems[index]);
  }

  Future<void> toggleAddonActiveToday(String title) => toggleAddonActive(title);
  Future<void> toggleAddonActiveTomorrow(String title) => toggleAddonActive(title);

  Future<void> deleteAddon(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) await deleteMenuItem(menuItems[index].id);
  }

  // --- MENU ITEM ACTIONS ---

  Future<void> toggleMenuItemActiveByName(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) await toggleMenuItemActive(menuItems[index]);
  }

  Future<void> deleteMenuItemByTitle(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) await deleteMenuItem(menuItems[index].id);
  }

  // --- SUBSCRIPTION PLAN ACTIONS ---

  Future<void> createCustomSubscriptionPlan({
    required String name,
    required String description,
    required double price,
    required String mealType,
    required int durationValue,
    required String durationType,
    required int mealsPerDay,
    required int totalMeals,
    required String deliveryFrequency,
    String? startsOn,
  }) async {
    _setLoading(true);
    try {
      final String durationTypeBackend = durationType.toLowerCase().contains('week')
          ? 'WEEK'
          : (durationType.toLowerCase().contains('day') ? 'DAY' : 'MONTH');

      final body = {
        'name': name,
        'title': name,
        'description': description.isNotEmpty ? description : '$totalMeals meals subscription',
        'price': price,
        'meal_type': mealType,
        'duration_value': durationValue,
        'duration_type': durationTypeBackend,
        'duration': '$durationValue $durationType',
        'meals_per_day': mealsPerDay,
        'total_meals': totalMeals,
        'meals_count': totalMeals,
        'delivery_frequency': deliveryFrequency,
        if (startsOn != null && startsOn.isNotEmpty) 'starts_on': startsOn,
        'taxes_and_disc': '5% GST included',
        'status': 'ACTIVE',
      };

      await _restaurantRepository.createPlan(body);
      subscriptionPlans = await _restaurantRepository.getPlans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateCustomSubscriptionPlan(
    int planId, {
    required String name,
    required String description,
    required double price,
    required String mealType,
    required int durationValue,
    required String durationType,
    required int mealsPerDay,
    required int totalMeals,
    required String deliveryFrequency,
    String? startsOn,
  }) async {
    _setLoading(true);
    try {
      final String durationTypeBackend = durationType.toLowerCase().contains('week')
          ? 'WEEK'
          : (durationType.toLowerCase().contains('day') ? 'DAY' : 'MONTH');

      final body = {
        'name': name,
        'title': name,
        'description': description.isNotEmpty ? description : '$totalMeals meals subscription',
        'price': price,
        'meal_type': mealType,
        'duration_value': durationValue,
        'duration_type': durationTypeBackend,
        'duration': '$durationValue $durationType',
        'meals_per_day': mealsPerDay,
        'total_meals': totalMeals,
        'meals_count': totalMeals,
        'delivery_frequency': deliveryFrequency,
        if (startsOn != null && startsOn.isNotEmpty) 'starts_on': startsOn,
        'taxes_and_disc': '5% GST included',
        'status': 'ACTIVE',
      };

      await _restaurantRepository.updatePlan(planId, body);
      subscriptionPlans = await _restaurantRepository.getPlans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> addSubscriptionPlan(String title, double price, String duration, String mealsCountStr, String mealType, String taxes) async {
    final int meals = int.tryParse(mealsCountStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
    await _restaurantRepository.createPlan({
      'name': title,
      'description': '$meals meals subscription',
      'price': price,
      'duration_value': duration.contains('Week') ? 7 : 30,
      'duration_type': duration.contains('Week') ? 'WEEK' : 'MONTH',
      'meal_type': mealType,
      'meals_per_day': 1,
      'total_meals': meals,
      'delivery_frequency': 'Daily',
      'status': 'ACTIVE',
    });
    subscriptionPlans = await _restaurantRepository.getPlans();
    notifyListeners();
  }

  Future<void> deleteSubscriptionPlan(String title) async {
    final index = subscriptionPlans.indexWhere((p) => p.title == title);
    if (index >= 0) await deletePlan(subscriptionPlans[index].id);
  }

  Future<void> deletePlan(int id) async {
    _setLoading(true);
    try {
      await _restaurantRepository.deletePlan(id);
      subscriptionPlans = await _restaurantRepository.getPlans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateOrderStatus(int id, String status, {String? deliveryOtp}) async {
    _setLoading(true);
    try {
      await _restaurantRepository.updateOrderStatus(id, status, deliveryOtp: deliveryOtp);
      orders = await _restaurantRepository.getOrders();

      try {
        await fetchNotifications();
      } catch (_) {}

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
}
