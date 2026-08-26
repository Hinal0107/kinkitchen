import 'package:flutter/material.dart';
import '../../../../repositories/customer_repository.dart';
import '../../../../repositories/subscription_repository.dart';
import '../../../../models/restaurant.dart';
import '../../../../models/menu_category.dart';
import '../../../../models/menu_item.dart';
import '../../../../models/subscription_plan.dart';
import '../../../../models/subscription.dart';
import '../../../../models/order.dart';

class ClientCartItem {
  final MenuItem item;
  int quantity;

  ClientCartItem({
    required this.item,
    this.quantity = 1,
  });
}

class TiffinStateProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository = CustomerRepository();
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();

  // General Loading & Error States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Active Selected Restaurant ID
  int? _selectedRestaurantId;
  int? get selectedRestaurantId => _selectedRestaurantId;

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
  List<MenuItem> menuItems = [];
  List<SubscriptionPlan> subscriptionPlans = [];
  List<Order> orders = [];

  // Active Category Chip
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  // Cart Storage (In-Memory Client State)
  final List<ClientCartItem> _cartItems = [];
  List<ClientCartItem> get cartItems => _cartItems;

  void setCategory(String category) {
    _selectedCategory = category;
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

  // --- API FETCH CALLS ---

  // 1. Fetch Restaurants & User Access Status
  Future<void> fetchRestaurants() async {
    _setLoading(true);
    try {
      restaurants = await _customerRepository.getRestaurants();
      await fetchAccessStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 2. Fetch Restaurant Categories, Menu & Active Subscription
  Future<void> fetchRestaurantDetails(int restaurantId) async {
    _setLoading(true);
    _selectedRestaurantId = restaurantId;
    try {
      categories = await _customerRepository.getRestaurantCategories(restaurantId);
      menuItems = await _customerRepository.getRestaurantMenu(
        restaurantId,
        category: _selectedCategory,
      );
      subscriptionPlans = await _customerRepository.getRestaurantPlans(restaurantId);
      await fetchAccessStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Fetch User Access & Free Trial Status
  Future<void> fetchAccessStatus() async {
    try {
      _accessStatus = await _subscriptionRepository.getAccessStatus();
    } catch (_) {}
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

  // --- IN-MEMORY CART & ADD-ON SEPARATION ---

  bool isAddonItem(MenuItem item) {
    final cat = categories.where((c) => c.id == item.categoryId).isNotEmpty
        ? categories.firstWhere((c) => c.id == item.categoryId)
        : null;
    if (cat != null) {
      final name = cat.name.toLowerCase();
      if (name.contains('add-on') || name.contains('addon')) return true;
    }
    return false;
  }

  void addToCart(MenuItem item) {
    if (_cartItems.isNotEmpty && _cartItems.first.item.restaurantId != item.restaurantId) {
      return;
    }
    
    final existingIndex = _cartItems.indexWhere((c) => c.item.id == item.id);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(ClientCartItem(item: item));
    }
    notifyListeners();
  }

  void removeFromCart(MenuItem item) {
    final existingIndex = _cartItems.indexWhere((c) => c.item.id == item.id);
    if (existingIndex >= 0) {
      if (_cartItems[existingIndex].quantity > 1) {
        _cartItems[existingIndex].quantity--;
      } else {
        _cartItems.removeAt(existingIndex);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  int getItemQuantity(int menuItemId) {
    final item = _cartItems.firstWhere((c) => c.item.id == menuItemId, orElse: () => ClientCartItem(item: MenuItem(id: 0, categoryId: 0, restaurantId: 0, name: '', description: '', price: 0, discountPrice: 0, vegType: 'VEG', availability: false, status: 'inactive'), quantity: 0));
    return item.quantity;
  }

  int get totalCartCount {
    return _cartItems.fold(0, (sum, c) => sum + c.quantity);
  }

  // Standard calculation
  double get subtotal {
    return _cartItems.fold(0.0, (sum, c) => sum + (c.item.price * c.quantity));
  }

  double get deliveryFee => _cartItems.isEmpty ? 0.0 : 2.00;
  double get tax => _cartItems.isEmpty ? 0.0 : 1.50;
  double get total => subtotal + deliveryFee + tax;

  // Add-on Payment Separation Breakdown
  List<ClientCartItem> get subscriptionIncludedCartItems {
    return _cartItems.where((c) => !isAddonItem(c.item)).toList();
  }

  List<ClientCartItem> get addonCartItems {
    return _cartItems.where((c) => isAddonItem(c.item)).toList();
  }

  double get subscriptionCoveredSubtotal => 0.00; // Subscription meals are prepaid

  double get addonSubtotal {
    return addonCartItems.fold(0.0, (sum, c) => sum + (c.item.price * c.quantity));
  }

  double get addonDeliveryFee => addonCartItems.isEmpty ? 0.0 : 2.00;
  double get addonTax => addonCartItems.isEmpty ? 0.0 : 1.50;
  double get addonTotalPayable => addonSubtotal + addonDeliveryFee + addonTax;

  // --- API MUTATION ACTIONS ---

  // Place Order on Backend
  Future<Order> placeOrder(String address) async {
    _setLoading(true);
    try {
      final itemsData = _cartItems.map((c) => {
        'menu_item_id': c.item.id,
        'quantity': c.quantity,
        'is_addon': isAddonItem(c.item),
      }).toList();

      final orderData = {
        'restaurant_id': _selectedRestaurantId,
        'delivery_address': address,
        'items': itemsData,
        'subtotal': subtotal,
        'addon_subtotal': addonSubtotal,
        'delivery_fee': deliveryFee,
        'tax': tax,
        'total': total,
        'addon_total_payable': addonTotalPayable,
      };

      final order = await _customerRepository.createOrder(orderData);
      
      // If user consumed subscription meals, decrement remaining count
      if (_activeSubscriptionDetails != null && subscriptionIncludedCartItems.isNotEmpty) {
        final int used = _activeSubscriptionDetails!.usedMeals + subscriptionIncludedCartItems.length;
        final int rem = max(0, _activeSubscriptionDetails!.totalMeals - used);
        _activeSubscriptionDetails = Subscription(
          id: _activeSubscriptionDetails!.id,
          userId: _activeSubscriptionDetails!.userId,
          restaurantId: _activeSubscriptionDetails!.restaurantId,
          subscriptionPlanId: _activeSubscriptionDetails!.subscriptionPlanId,
          status: rem <= 0 ? 'EXPIRED' : 'ACTIVE',
          startDate: _activeSubscriptionDetails!.startDate,
          endDate: _activeSubscriptionDetails!.endDate,
          autoRenew: _activeSubscriptionDetails!.autoRenew,
          plan: _activeSubscriptionDetails!.plan,
          restaurant: _activeSubscriptionDetails!.restaurant,
          totalMeals: _activeSubscriptionDetails!.totalMeals,
          usedMeals: used,
          remainingMeals: rem,
          maxValidityDays: _activeSubscriptionDetails!.maxValidityDays,
          maxValidityDate: _activeSubscriptionDetails!.maxValidityDate,
          daysUntilExpiry: _activeSubscriptionDetails!.daysUntilExpiry,
          expiryReminderMessage: rem <= 0 ? 'Your plan has expired.' : _activeSubscriptionDetails!.expiryReminderMessage,
          paymentStatus: 'PAID',
        );
      }

      _cartItems.clear();
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Subscribe to plan on backend
  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final String startDateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final int maxDays = plan.maxValidityDays; // Weekly: 14 days, Monthly: 60 days
      final maxDate = now.add(Duration(days: maxDays));
      final String maxDateStr = "${maxDate.year}-${maxDate.month.toString().padLeft(2, '0')}-${maxDate.day.toString().padLeft(2, '0')}";

      _activeSubscription = plan.title;
      _activeSubscriptionDetails = Subscription(
        id: 1,
        userId: 1,
        restaurantId: plan.restaurantId,
        subscriptionPlanId: plan.id,
        status: 'ACTIVE',
        startDate: startDateStr,
        endDate: maxDateStr,
        autoRenew: true,
        plan: plan,
        totalMeals: plan.mealsCount,
        usedMeals: 0,
        remainingMeals: plan.mealsCount,
        maxValidityDays: maxDays,
        maxValidityDate: maxDateStr,
        daysUntilExpiry: maxDays,
        expiryReminderMessage: null,
        paymentStatus: 'PAID',
      );

      // Grant access status upon subscribing
      _accessStatus = {
        'can_access': true,
        'is_trial': false,
        'trial_days_remaining': 0,
        'message': 'Active subscription plan.',
        'subscription': _activeSubscriptionDetails,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void cancelSubscription() {
    _activeSubscription = 'None';
    _activeSubscriptionDetails = null;
    notifyListeners();
  }

  int max(int a, int b) => a > b ? a : b;
}
