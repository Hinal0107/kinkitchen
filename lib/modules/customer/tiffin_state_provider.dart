import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kinkitchen/shared/repositories/customer_repository.dart';
import 'package:kinkitchen/shared/repositories/subscription_repository.dart';
import 'package:kinkitchen/shared/models/restaurant.dart';
import 'package:kinkitchen/shared/models/menu_category.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';
import 'package:kinkitchen/shared/models/subscription_plan.dart';
import 'package:kinkitchen/shared/models/subscription.dart';
import 'package:kinkitchen/shared/models/order.dart';

import 'package:kinkitchen/shared/repositories/address_repository.dart';
import 'package:kinkitchen/shared/repositories/cart_repository.dart';
import 'package:kinkitchen/shared/repositories/order_repository.dart';
import 'package:kinkitchen/shared/models/address.dart';

import 'package:kinkitchen/shared/repositories/auth_repository.dart';
import 'package:kinkitchen/shared/repositories/notification_repository.dart';
import 'package:kinkitchen/shared/models/user.dart';
import 'package:kinkitchen/shared/models/notification_item.dart';

class ClientCartItem {
  final MenuItem item;
  int quantity;
  final String itemType; // 'Today Meal', 'Tomorrow Meal', 'Weekly Meal', 'Add-on', 'Menu Item'
  final int? cartItemId;

  ClientCartItem({
    required this.item,
    this.quantity = 1,
    this.itemType = 'Menu Item',
    this.cartItemId,
  });

  double get unitPrice => item.price;
  double get subtotal => unitPrice * quantity;
}

class TiffinStateProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository = CustomerRepository();
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  final AddressRepository _addressRepository = AddressRepository();
  final CartRepository _cartRepository = CartRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final AuthRepository _authRepository = AuthRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();

  User? currentUser;

  // Notification State
  List<NotificationItem> notifications = [];
  int unreadNotificationCount = 0;

  // General Loading & Error States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Active Selected Restaurant
  int? _selectedRestaurantId;
  int? get selectedRestaurantId => _selectedRestaurantId;

  Restaurant? _selectedRestaurant;
  Restaurant? get selectedRestaurant => _selectedRestaurant;

  // Active Subscription State
  String _activeSubscription = 'None';
  String get activeSubscription => _activeSubscription;

  Subscription? _activeSubscriptionDetails;
  Subscription? get activeSubscriptionDetails => _activeSubscriptionDetails;

  // User Access Status & Trial Info
  Map<String, dynamic>? _accessStatus = {
    'can_access': true,
    'is_trial': true,
    'trial_days_remaining': 7,
    'message': 'Initial 7-day free trial active.',
  };
  Map<String, dynamic>? get accessStatus => _accessStatus;

  bool get canAccessMeals => _accessStatus?['can_access'] as bool? ?? true;
  bool get isInFreeTrial => _accessStatus?['is_trial'] as bool? ?? true;
  int get trialDaysRemaining => (_accessStatus?['trial_days_remaining'] as int?) ?? 7;

  // Lists fetched from API
  List<Restaurant> restaurants = [];
  List<MenuCategory> categories = [];
  List<MenuItem> todayMeals = [];
  List<MenuItem> tomorrowMeals = [];
  List<MenuItem> weeklyMeals = [];
  List<MenuItem> addons = [];
  List<MenuItem> menuItems = [];
  List<SubscriptionPlan> subscriptionPlans = [];
  List<Order> orders = [];
  List<Order> get customerOrders => orders;
  List<Address> addresses = [];
  Address? selectedAddress;
  Map<String, dynamic> restaurantTaxConfig = {};

  // Active Category Chip
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  // Cart Storage (In-Memory Client State)
  final List<ClientCartItem> _cartItems = [];
  List<ClientCartItem> get cartItems => _cartItems;

  bool _isInitialDataLoaded = false;
  bool get isInitialDataLoaded => _isInitialDataLoaded;
  bool _isFetchingSelectedData = false;
  int? _lastFetchedRestaurantId;

  TiffinStateProvider() {
    _loadStoredSelectedRestaurant();
  }

  Future<void> _loadStoredSelectedRestaurant() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedRestaurantId = prefs.getInt('selected_restaurant_id');
    if (_selectedRestaurantId == null) {
      try {
        restaurants = await _customerRepository.getRestaurants();
        if (restaurants.isNotEmpty) {
          _selectedRestaurantId = restaurants.first.id;
          _selectedRestaurant = restaurants.first;
          await prefs.setInt('selected_restaurant_id', _selectedRestaurantId!);
        } else {
          _selectedRestaurantId = 1;
        }
      } catch (_) {
        _selectedRestaurantId = 1;
      }
    }
    await fetchSelectedRestaurantData();
  }

  Future<void> selectRestaurant(Restaurant restaurant) async {
    // If switching to a different restaurant, clear previous cart items
    if (_selectedRestaurantId != null && _selectedRestaurantId != restaurant.id) {
      _cartItems.clear();
    }
    _selectedRestaurantId = restaurant.id;
    _selectedRestaurant = restaurant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_restaurant_id', restaurant.id);
    
    // Call backend API if endpoint exists
    try {
      await _customerRepository.setSelectedRestaurant(restaurant.id);
    } catch (_) {}

    notifyListeners();
    await fetchSelectedRestaurantData(forceRefresh: true);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    if (_selectedRestaurantId != null) {
      fetchRestaurantMenu();
    } else {
      notifyListeners();
    }
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

  // Dynamic Tax / GST Percentage from Backend Configuration
  double get taxRatePercentage {
    if (restaurantTaxConfig.containsKey('tax_rate')) {
      final val = restaurantTaxConfig['tax_rate'];
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 5.0;
    }
    if (restaurantTaxConfig.containsKey('gst_percentage')) {
      final val = restaurantTaxConfig['gst_percentage'];
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 5.0;
    }
    if (restaurantTaxConfig.containsKey('tax_percentage')) {
      final val = restaurantTaxConfig['tax_percentage'];
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 5.0;
    }
    return 5.0; // Default 5% GST if not specified
  }

  // --- API FETCH CALLS ---

  // 1. Fetch Restaurants List & Access Status
  Future<void> fetchRestaurants() async {
    _setLoading(true);
    try {
      restaurants = await _customerRepository.getRestaurants();
      if (_selectedRestaurantId != null && restaurants.isNotEmpty) {
        final found = restaurants.where((r) => r.id == _selectedRestaurantId);
        if (found.isNotEmpty) {
          _selectedRestaurant = found.first;
        }
      }
      await fetchAccessStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 2. Fetch All Data for Currently Selected Restaurant
  Future<void> fetchRestaurantDetails(int restaurantId) async {
    _selectedRestaurantId = restaurantId;
    await fetchSelectedRestaurantData(forceRefresh: true);
  }

  Future<void> fetchSelectedRestaurantData({bool forceRefresh = false}) async {
    if (_selectedRestaurantId == null) {
      _selectedRestaurantId = 1;
    }
    
    // Prevent duplicate parallel or unnecessary repeated requests
    if (_isFetchingSelectedData) {
      debugPrint('TiffinState: fetchSelectedRestaurantData skipped - already fetching');
      return;
    }
    if (!forceRefresh && _isInitialDataLoaded && _lastFetchedRestaurantId == _selectedRestaurantId) {
      debugPrint('TiffinState: fetchSelectedRestaurantData skipped - data already loaded for restaurant $_selectedRestaurantId');
      return;
    }

    _isFetchingSelectedData = true;
    debugPrint('TiffinState: fetchSelectedRestaurantData started');
    _setLoading(true);

    try {
      final resId = _selectedRestaurantId!;
      // Fetch details in parallel / sequence
      try {
        _selectedRestaurant = await _customerRepository.getRestaurantDetails(resId);
      } catch (_) {}

      try {
        categories = await _customerRepository.getRestaurantCategories(resId);
      } catch (_) {}

      try {
        todayMeals = await _customerRepository.getTodayMeal(resId);
      } catch (_) {
        todayMeals = [];
      }

      try {
        tomorrowMeals = await _customerRepository.getTomorrowMeal(resId);
      } catch (_) {
        tomorrowMeals = [];
      }

      try {
        weeklyMeals = await _customerRepository.getWeeklyMeal(resId);
      } catch (_) {
        weeklyMeals = [];
      }

      try {
        addons = await _customerRepository.getRestaurantAddons(resId);
      } catch (_) {
        addons = [];
      }

      try {
        menuItems = await _customerRepository.getRestaurantMenu(resId, category: _selectedCategory);
      } catch (_) {
        menuItems = [];
      }

      try {
        subscriptionPlans = await _customerRepository.getRestaurantPlans(resId);
      } catch (_) {
        subscriptionPlans = [];
      }

      try {
        restaurantTaxConfig = await _customerRepository.getRestaurantTaxes(resId);
      } catch (_) {
        restaurantTaxConfig = {};
      }

      await fetchAddresses();
      await fetchAccessStatus();
      await fetchActiveSubscription();
      await fetchCurrentUserProfile();
      await fetchNotifications();

      _isInitialDataLoaded = true;
      _lastFetchedRestaurantId = resId;
      _isFetchingSelectedData = false;
      _isLoading = false;
      debugPrint('TiffinState: fetchSelectedRestaurantData completed');
      notifyListeners();
    } catch (e) {
      _isFetchingSelectedData = false;
      _setError(e.toString());
    }
  }

  // --- USER PROFILE MANAGEMENT ---
  Future<void> fetchCurrentUserProfile() async {
    try {
      currentUser = await _authRepository.getMe();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateUserProfile({required String name, required String phone, File? image}) async {
    _setLoading(true);
    try {
      currentUser = await _authRepository.updateProfile(name: name, phone: phone, image: image);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> deleteUserAccount() async {
    _setLoading(true);
    try {
      await _authRepository.deleteAccount();
      currentUser = null;
      clearCart();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Fetch Addresses
  Future<void> fetchAddresses() async {
    try {
      addresses = await _addressRepository.getAddresses();
      if (addresses.isNotEmpty) {
        final def = addresses.where((a) => a.isDefault);
        selectedAddress = def.isNotEmpty ? def.first : addresses.first;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> createAddress({
    required String label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pincode,
    bool isDefault = false,
  }) async {
    try {
      final newAddr = await _addressRepository.createAddress(
        label: label,
        line1: line1,
        line2: line2,
        city: city,
        state: state,
        pincode: pincode,
        isDefault: isDefault,
      );
      await fetchAddresses();
      selectedAddress = newAddr;
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  // Fetch Categories & Menu Items from API
  Future<void> fetchRestaurantMenu() async {
    if (_selectedRestaurantId == null) return;
    try {
      final resId = _selectedRestaurantId!;
      categories = await _customerRepository.getRestaurantCategories(resId);
      menuItems = await _customerRepository.getRestaurantMenu(
        resId,
        category: _selectedCategory,
      );
      notifyListeners();
    } catch (_) {}
  }

  // Fetch User Access & Free Trial Status
  Future<void> fetchAccessStatus() async {
    try {
      _accessStatus = await _subscriptionRepository.getAccessStatus();
    } catch (_) {}
  }

  // Fetch Active Customer Subscriptions from Backend
  Future<void> fetchActiveSubscription() async {
    try {
      final subs = await _subscriptionRepository.getMySubscriptions();
      final activeList = subs.where((s) {
        final st = s.status.toUpperCase();
        return (st == 'ACTIVE' || st == 'PAID') && s.remainingMeals > 0 && s.daysUntilExpiry >= 0 && !s.isExpiredStatus;
      }).toList();

      if (activeList.isNotEmpty) {
        _activeSubscriptionDetails = activeList.first;
        _activeSubscription = activeList.first.plan?.title ?? 'Active Plan';
      } else if (_activeSubscriptionDetails != null && _activeSubscriptionDetails!.remainingMeals > 0 && !_activeSubscriptionDetails!.isExpiredStatus) {
        // Keep current valid in-memory subscription
      } else {
        _activeSubscription = 'None';
        _activeSubscriptionDetails = null;
      }
      notifyListeners();
    } catch (_) {}
  }

  // Fetch Notifications & Unread Count
  Future<void> fetchNotifications() async {
    try {
      notifications = await _notificationRepository.getNotifications();
      unreadNotificationCount = await _notificationRepository.getUnreadCount();
      notifyListeners();
    } catch (_) {
      // Fallback count calculation if API fails
      unreadNotificationCount = notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<void> fetchCustomerOrders() async {
    _setLoading(true);
    try {
      orders = await _customerRepository.getOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _setError(e.toString());
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

  // Subscription Actions
  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    if (hasActiveSubscription && remainingSubscriptionMeals > 0) {
      throw Exception('You already have an active subscription with $remainingSubscriptionMeals meals remaining. Per Terms & Conditions, you can continue using your active plan every day until all meals are completed or expired before purchasing a new plan.');
    }

    _activeSubscription = plan.title;
    try {
      final resId = _selectedRestaurantId ?? plan.restaurantId;
      final sub = await _subscriptionRepository.subscribe(
        restaurantId: resId,
        subscriptionPlanId: plan.id,
        startDate: DateTime.now().toIso8601String().split('T').first,
        addressId: selectedAddress?.id ?? 1,
      );
      _activeSubscriptionDetails = sub;
    } catch (_) {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: plan.maxValidityDays));
      _activeSubscriptionDetails = Subscription(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        userId: currentUser?.id ?? 1,
        restaurantId: _selectedRestaurantId ?? plan.restaurantId,
        subscriptionPlanId: plan.id,
        status: 'ACTIVE',
        startDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        endDate: '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
        autoRenew: true,
        plan: plan,
        restaurant: _selectedRestaurant,
        totalMeals: plan.mealsCount,
        usedMeals: 0,
        remainingMeals: plan.mealsCount,
        maxValidityDays: plan.maxValidityDays,
        maxValidityDate: '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
        daysUntilExpiry: plan.maxValidityDays,
      );
    }

    try {
      await _notificationRepository.sendNotification(
        title: 'Subscription Activated',
        body: 'You have successfully subscribed to ${plan.title}. Your plan is active and valid for daily meal orders.',
        role: 'CUSTOMER',
      );
      await fetchNotifications();
    } catch (_) {}

    notifyListeners();
  }

  Future<void> pauseSubscription([int? subscriptionId]) async {
    final subId = subscriptionId ?? _activeSubscriptionDetails?.id;
    if (subId != null) {
      try {
        final updated = await _subscriptionRepository.pauseSubscription(subId);
        _activeSubscriptionDetails = updated;
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> resumeSubscription([int? subscriptionId]) async {
    final subId = subscriptionId ?? _activeSubscriptionDetails?.id;
    if (subId != null) {
      try {
        final updated = await _subscriptionRepository.resumeSubscription(subId);
        _activeSubscriptionDetails = updated;
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> cancelSubscription([int? subscriptionId]) async {
    final subId = subscriptionId ?? _activeSubscriptionDetails?.id;
    if (subId != null) {
      try {
        final updated = await _subscriptionRepository.cancelSubscription(subId);
        _activeSubscriptionDetails = updated;
      } catch (_) {}
    }
    _activeSubscription = 'None';

    try {
      await _notificationRepository.sendNotification(
        title: 'Subscription Cancelled',
        body: 'Your active subscription has been cancelled.',
        role: 'CUSTOMER',
      );
      await fetchNotifications();
    } catch (_) {}

    notifyListeners();
  }

  // Fetch Orders History
  Future<void> fetchOrders() async {
    _setLoading(true);
    try {
      orders = await _customerRepository.getOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // --- CART MANAGEMENT ---

  void addToCart(MenuItem item, {String itemType = 'Menu Item', int quantity = 1}) {
    if (_selectedRestaurantId != null && item.restaurantId != _selectedRestaurantId) {
      // Prevent mixing items from different restaurants
      _cartItems.clear();
    }

    final existingIndex = _cartItems.indexWhere((c) => c.item.id == item.id && c.itemType == itemType);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(ClientCartItem(item: item, quantity: quantity, itemType: itemType));
    }
    notifyListeners();
  }

  void removeFromCart(MenuItem item, {String itemType = 'Menu Item'}) {
    final existingIndex = _cartItems.indexWhere((c) => c.item.id == item.id && c.itemType == itemType);
    if (existingIndex >= 0) {
      if (_cartItems[existingIndex].quantity > 1) {
        _cartItems[existingIndex].quantity--;
      } else {
        _cartItems.removeAt(existingIndex);
      }
    }
    notifyListeners();
  }

  void updateCartQuantity(int menuItemId, String itemType, int newQuantity) {
    final existingIndex = _cartItems.indexWhere((c) => c.item.id == menuItemId && c.itemType == itemType);
    if (existingIndex >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(existingIndex);
      } else {
        _cartItems[existingIndex].quantity = newQuantity;
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  int getItemQuantity(int menuItemId, {String? itemType}) {
    if (itemType != null) {
      final found = _cartItems.where((c) => c.item.id == menuItemId && c.itemType == itemType);
      return found.isNotEmpty ? found.first.quantity : 0;
    }
    final found = _cartItems.where((c) => c.item.id == menuItemId);
    return found.fold(0, (sum, c) => sum + c.quantity);
  }

  int get totalCartCount {
    return _cartItems.fold(0, (sum, c) => sum + c.quantity);
  }

  // Subtotal = Sum of (Unit Price x Quantity)
  double get subtotal {
    return _cartItems.fold(0.0, (sum, c) => sum + c.subtotal);
  }

  // Tax / GST calculated dynamically based on backend tax configuration
  double get taxAmount {
    if (_cartItems.isEmpty) return 0.0;
    return subtotal * (taxRatePercentage / 100.0);
  }

  double get deliveryFee => _cartItems.isEmpty ? 0.0 : 2.00;
  double get total => subtotal + taxAmount + deliveryFee;

  // Add-on Payment Breakdown
  List<ClientCartItem> get addonCartItems {
    return _cartItems.where((c) => c.itemType == 'Add-on').toList();
  }

  double get addonSubtotal {
    return addonCartItems.fold(0.0, (sum, c) => sum + c.subtotal);
  }

  double get addonTaxAmount {
    if (addonCartItems.isEmpty) return 0.0;
    return addonSubtotal * (taxRatePercentage / 100.0);
  }

  double get addonDeliveryFee => addonCartItems.isEmpty ? 0.0 : 2.00;
  double get addonTotalPayable => addonSubtotal + addonTaxAmount + addonDeliveryFee;

  // --- SUBSCRIPTION & MEAL DEDUCTION CALCULATIONS ---

  bool get hasActiveSubscription {
    if (_activeSubscriptionDetails != null) {
      final sub = _activeSubscriptionDetails!;
      final s = sub.status.toUpperCase();
      if ((s == 'ACTIVE' || s == 'PAID') && sub.remainingMeals > 0 && sub.daysUntilExpiry >= 0 && !sub.isExpiredStatus) {
        return true;
      }
      return false;
    }
    return _activeSubscription != 'None';
  }

  int get remainingSubscriptionMeals {
    if (_activeSubscriptionDetails != null) {
      return _activeSubscriptionDetails!.remainingMeals;
    }
    return hasActiveSubscription ? 14 : 0;
  }

  int get subscriptionMealsInCart {
    return _cartItems.where((c) => c.itemType != 'Add-on').fold(0, (sum, c) => sum + c.quantity);
  }

  int get addonItemsInCartCount {
    return _cartItems.where((c) => c.itemType == 'Add-on').fold(0, (sum, c) => sum + c.quantity);
  }

  // --- DETAILED ORDER & PAYMENT BREAKDOWN (Image 15 & 16) ---

  double get subscriptionCoveredAmount {
    if (!hasActiveSubscription || subscriptionMealsInCart <= 0) return 0.0;
    final double mainMealsSubtotal = _cartItems.where((c) => c.itemType != 'Add-on').fold(0.0, (sum, c) => sum + c.subtotal);
    return mainMealsSubtotal;
  }

  double get additionalMealAmount => 0.0;

  double get addonAmount => addonSubtotal;

  double get discountAmount => 0.0;

  double get totalAmount => subtotal + effectiveTaxAmount + effectiveDeliveryFee;

  double get customerPaidAmount => (totalAmount - subscriptionCoveredAmount).clamp(0.0, 99999.0);

  double get remainingAmount => 0.0;

  double get effectiveSubtotal {
    if (hasActiveSubscription) {
      return addonSubtotal;
    }
    return subtotal;
  }

  double get effectiveTaxAmount {
    if (hasActiveSubscription) {
      return addonTaxAmount;
    }
    return taxAmount;
  }

  double get effectiveDeliveryFee {
    if (_cartItems.isEmpty) return 0.0;
    if (hasActiveSubscription && addonCartItems.isEmpty) return 0.0;
    return 2.00;
  }

  double get effectiveTotal {
    if (hasActiveSubscription) {
      return customerPaidAmount;
    }
    return total;
  }

  // --- API ORDER MUTATION ---

  Future<Order> placeOrder(String address, {int? addressId, String? deliveryNotes, bool simulateWorldpay = true}) async {
    _setLoading(true);
    try {
      final itemsData = _cartItems.map((c) {
        final bool isAddon = c.itemType == 'Add-on' || c.item.isAddon;
        final bool isDailyMeal = c.itemType.contains('Meal') ||
            c.itemType == 'Today Meal' ||
            c.itemType == 'Tomorrow Meal' ||
            (c.item.mealType != null && c.item.mealType!.isNotEmpty);

        // Resolve valid menu_item_id that exists in database menu_items table
        int resolvedMenuItemId = c.item.id;
        if (menuItems.isNotEmpty) {
          final idMatch = menuItems.where((m) => m.id == c.item.id);
          if (idMatch.isNotEmpty) {
            resolvedMenuItemId = idMatch.first.id;
          } else {
            final nameMatch = menuItems.where((m) =>
                m.name.toLowerCase().contains(c.item.name.toLowerCase()) ||
                c.item.name.toLowerCase().contains(m.name.toLowerCase()));
            if (nameMatch.isNotEmpty) {
              resolvedMenuItemId = nameMatch.first.id;
            } else {
              resolvedMenuItemId = menuItems.first.id;
            }
          }
        }

        return {
          'menu_item_id': resolvedMenuItemId,
          if (isDailyMeal) 'daily_meal_id': c.item.id,
          if (isAddon) 'addon_id': c.item.id,
          'item_id': resolvedMenuItemId,
          'name': c.item.name,
          'quantity': c.quantity,
          'item_type': c.itemType,
          'is_addon': isAddon,
          'unit_price': c.item.price,
          'price': c.item.price,
          'subtotal': c.subtotal,
          'subscription_eligible': !isAddon && hasActiveSubscription,
          'subscription_meals_used': (!isAddon && hasActiveSubscription) ? c.quantity : 0,
        };
      }).toList();

      final int targetAddressId = addressId ?? selectedAddress?.id ?? 1;
      final bool isSubscribed = hasActiveSubscription;
      final int mealsCount = subscriptionMealsInCart;

      final orderData = {
        'restaurant_id': _selectedRestaurantId ?? 1,
        'address_id': targetAddressId,
        'delivery_address': address,
        if (deliveryNotes != null && deliveryNotes.isNotEmpty) 'delivery_notes': deliveryNotes,
        if (isSubscribed && mealsCount > 0) 'include_subscription_meal': 1,
        if (isSubscribed && _activeSubscriptionDetails != null) 'subscription_id': _activeSubscriptionDetails!.id,
        'payment_source': isSubscribed ? 'subscription' : 'card',
        'items': itemsData,
        'subtotal': subtotal,
        'tax': taxAmount,
        'tax_rate_percentage': taxRatePercentage,
        'delivery_fee': effectiveDeliveryFee,
        'subscription_amount': subscriptionCoveredAmount,
        'additional_meal_amount': additionalMealAmount,
        'addon_amount': addonAmount,
        'tax_amount': taxAmount,
        'discount_amount': discountAmount,
        'total_amount': totalAmount,
        'paid_amount': customerPaidAmount,
        'remaining_amount': remainingAmount,
        'total': totalAmount,
      };

      final order = await _customerRepository.createOrder(orderData);

      // Per Rule 2 & Rule 6: Placing an order does NOT immediately consume a meal.
      // The subscription meal is consumed only when the order status becomes DELIVERED.
      try {
        await fetchNotifications();
      } catch (_) {}

      clearCart();
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<Order> confirmOrderReceipt(int orderId) async {
    _setLoading(true);
    try {
      final updatedOrder = await _customerRepository.confirmOrderReceived(orderId);
      final idx = orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        orders[idx] = updatedOrder;
      }
      // Re-fetch active subscription state from backend transaction
      await fetchActiveSubscription();
      _isLoading = false;
      notifyListeners();
      return updatedOrder;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
}
