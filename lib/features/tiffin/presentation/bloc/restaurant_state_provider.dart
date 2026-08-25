import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../repositories/restaurant_repository.dart';
import '../../../../models/restaurant.dart';
import '../../../../models/menu_category.dart';
import '../../../../models/menu_item.dart';
import '../../../../models/subscription_plan.dart';
import '../../../../models/order.dart';

class RestaurantStateProvider extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();

  // General Loading & Error States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Demo State: Toggle between Empty Kitchen and Filled Dashboard
  bool _isKitchenEmpty = false;
  bool get isKitchenEmpty => _isKitchenEmpty;

  // Models fetched from API
  Restaurant? profile;
  List<MenuCategory> categories = [];
  List<MenuItem> menuItems = [];
  List<SubscriptionPlan> subscriptionPlans = [];
  List<Order> orders = [];

  void toggleKitchenState() {
    _isKitchenEmpty = !_isKitchenEmpty;
    notifyListeners();
  }

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

  // --- COMPATIBLE GETTERS MAPPING BACKEND MODELS TO UI WIDGETS ---

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

  List<Map<String, dynamic>> get todayAddons {
    final cat = addonsCategory;
    if (cat == null) return [];
    return menuItems.where((item) => item.categoryId == cat.id).map((item) => {
      'id': item.id,
      'title': item.name,
      'price': item.price,
      'isVeg': item.vegType == 'VEG' || item.vegType == 'JAIN',
      'isActiveToday': item.availability,
      'availableQty': item.availability ? 50 : 0,
      'totalQty': 50,
    }).toList();
  }

  List<Map<String, dynamic>> get tomorrowAddons {
    final cat = addonsCategory;
    if (cat == null) return [];
    return menuItems.where((item) => item.categoryId == cat.id).map((item) => {
      'id': item.id,
      'title': item.name,
      'price': item.price,
      'isVeg': item.vegType == 'VEG' || item.vegType == 'JAIN',
      'isActiveTomorrow': item.availability,
      'availableQty': item.availability ? 50 : 0,
      'totalQty': 50,
    }).toList();
  }

  List<Map<String, dynamic>> get menuItemsMap {
    return menuItems.map((item) {
      final categoryName = categories.firstWhere(
        (c) => c.id == item.categoryId, 
        orElse: () => MenuCategory(id: 0, restaurantId: 0, name: 'Lunch', description: '', status: 'active')
      ).name;
      return {
        'id': item.id,
        'title': item.name,
        'price': item.price,
        'isVeg': item.vegType == 'VEG' || item.vegType == 'JAIN',
        'isActive': item.availability,
        'category': categoryName,
        'description': item.description,
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
      'isActive': p.status == 'active',
      'period': p.duration == 'Weekly' ? '/week' : '/month',
    }).toList();
  }

  List<Map<String, dynamic>> get todayMeals {
    final DateTime now = DateTime.now();
    final String todayDmy = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final String todayYmd = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final addonCat = addonsCategory;
    final meals = addonCat == null 
        ? menuItems.where((item) => item.scheduleDate == null || item.scheduleDate!.isEmpty || item.scheduleDate == todayDmy || item.scheduleDate == todayYmd)
        : menuItems.where((item) => item.categoryId != addonCat.id && (item.scheduleDate == null || item.scheduleDate!.isEmpty || item.scheduleDate == todayDmy || item.scheduleDate == todayYmd));

    return meals.map((item) => {
      'title': item.name,
      'price': item.price,
      'gst': '5%',
      'availableQty': item.availability ? 50 : 0,
      'totalQty': 50,
      'isActive': item.availability,
      'createdAt': 'Today',
      'isVeg': item.vegType == 'VEG' || item.vegType == 'JAIN',
    }).toList();
  }

  List<Map<String, dynamic>> get tomorrowMeals {
    final DateTime tom = DateTime.now().add(const Duration(days: 1));
    final String tomDmy = '${tom.day.toString().padLeft(2, '0')}/${tom.month.toString().padLeft(2, '0')}/${tom.year}';
    final String tomYmd = '${tom.year}-${tom.month.toString().padLeft(2, '0')}-${tom.day.toString().padLeft(2, '0')}';

    final addonCat = addonsCategory;
    final meals = addonCat == null
        ? menuItems.where((item) => item.scheduleDate == tomDmy || item.scheduleDate == tomYmd)
        : menuItems.where((item) => item.categoryId != addonCat.id && (item.scheduleDate == tomDmy || item.scheduleDate == tomYmd));

    return meals.map((item) => {
      'title': item.name,
      'price': item.price,
      'availableQty': 50,
      'totalQty': 50,
      'isActive': item.availability,
      'isVeg': item.vegType == 'VEG' || item.vegType == 'JAIN',
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
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
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

  Future<void> addMenuItem(Map<String, String> fields, {File? image}) async {
    _setLoading(true);
    try {
      await _restaurantRepository.createMenuItem(fields, image: image);
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
        'status': item.status,
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

  // --- SCREEN COMPATIBILITY WRAPPERS ---

  Future<void> addTodayMeal(String title, double price, int qty, bool isVeg) async {
    // Add today's meal as a MenuItem
    await addMenuItem({
      'category_id': categories.isNotEmpty ? categories.first.id.toString() : '1',
      'restaurant_id': profile?.id.toString() ?? '1',
      'name': title,
      'description': 'Serving fresh today.',
      'price': price.toString(),
      'veg_type': isVeg ? 'VEG' : 'NON_VEG',
      'availability': '1',
      'status': 'Active',
    });
  }

  Future<void> toggleTodayMealActive(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) {
      await toggleMenuItemActive(menuItems[index]);
    }
  }

  Future<void> toggleMenuItemActiveByName(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) {
      await toggleMenuItemActive(menuItems[index]);
    }
  }

  Future<void> deleteTodayMeal(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) {
      await deleteMenuItem(menuItems[index].id);
    }
  }

  Future<void> addTomorrowMeal(String title) async {
    // Mark tomorrow meal active
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0 && !menuItems[index].availability) {
      await toggleMenuItemActive(menuItems[index]);
    }
  }

  Future<void> deleteTomorrowMeal(String title) async {
    // Mark tomorrow meal inactive
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0 && menuItems[index].availability) {
      await toggleMenuItemActive(menuItems[index]);
    }
  }

  Future<void> addSubscriptionPlan(String title, double price, String duration, String mealsCountStr, String mealType, String taxes) async {
    final int meals = int.tryParse(mealsCountStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
    await _restaurantRepository.createPlan({
      'restaurant_id': profile?.id ?? 1,
      'title': title,
      'price': price,
      'duration': duration,
      'meals_count': meals,
      'meal_type': mealType,
      'taxes_and_disc': taxes,
      'is_popular': false,
      'status': 'Active',
    });
    subscriptionPlans = await _restaurantRepository.getPlans();
    notifyListeners();
  }

  Future<void> deleteSubscriptionPlan(String title) async {
    final index = subscriptionPlans.indexWhere((p) => p.title == title);
    if (index >= 0) {
      await deletePlan(subscriptionPlans[index].id);
    }
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

  Future<void> updateOrderStatus(int id, String status) async {
    _setLoading(true);
    try {
      await _restaurantRepository.updateOrderStatus(id, status);
      orders = await _restaurantRepository.getOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // --- ADDON MANAGEMENT ACTIONS ---

  Future<int> _getOrCreateAddonsCategoryId() async {
    final cat = addonsCategory;
    if (cat != null) {
      return cat.id;
    }
    // Create Category named "Add-ons"
    await createCategory('Add-ons', 'Extra side dishes and beverages', 'active');
    final newCat = addonsCategory;
    return newCat?.id ?? 1;
  }

  Future<void> addAddon(String title, double price, int qty, bool isVeg) async {
    _setLoading(true);
    try {
      final categoryId = await _getOrCreateAddonsCategoryId();
      await addMenuItem({
        'category_id': categoryId.toString(),
        'restaurant_id': profile?.id.toString() ?? '1',
        'name': title,
        'description': 'Add-on item',
        'price': price.toString(),
        'veg_type': isVeg ? 'VEG' : 'NON_VEG',
        'availability': '1',
        'status': 'Active',
      });
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> toggleAddonActiveToday(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) {
      await toggleMenuItemActive(menuItems[index]);
    }
  }

  Future<void> toggleAddonActiveTomorrow(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) {
      await toggleMenuItemActive(menuItems[index]);
    }
  }

  Future<void> deleteAddon(String title) async {
    final index = menuItems.indexWhere((item) => item.name == title);
    if (index >= 0) {
      await deleteMenuItem(menuItems[index].id);
    }
  }
}
