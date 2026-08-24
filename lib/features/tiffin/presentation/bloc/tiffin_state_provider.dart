import 'package:flutter/material.dart';
import '../../../../repositories/customer_repository.dart';
import '../../../../models/restaurant.dart';
import '../../../../models/menu_category.dart';
import '../../../../models/menu_item.dart';
import '../../../../models/subscription_plan.dart';
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

  // General Loading & Error States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Active Selected Restaurant ID
  int? _selectedRestaurantId;
  int? get selectedRestaurantId => _selectedRestaurantId;

  // Active Subscription Plan ID
  String _activeSubscription = 'None';
  String get activeSubscription => _activeSubscription;

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

  // 1. Fetch Restaurants
  Future<void> fetchRestaurants() async {
    _setLoading(true);
    try {
      restaurants = await _customerRepository.getRestaurants();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 2. Fetch Restaurant Categories & Menu
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
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 3. Fetch Orders History
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

  // --- IN-MEMORY CART MANAGEMENT ---

  void addToCart(MenuItem item) {
    // Cart validation: A cart must belong to a single restaurant
    if (_cartItems.isNotEmpty && _cartItems.first.item.restaurantId != item.restaurantId) {
      // Handled in UI by showing dialog to clear cart first
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

  double get subtotal {
    return _cartItems.fold(0.0, (sum, c) => sum + (c.item.price * c.quantity));
  }

  double get deliveryFee => _cartItems.isEmpty ? 0.0 : 2.00;
  double get tax => _cartItems.isEmpty ? 0.0 : 1.50;
  double get total => subtotal + deliveryFee + tax;

  // --- API MUTATION ACTIONS ---

  // Place Order on Backend
  Future<Order> placeOrder(String address) async {
    _setLoading(true);
    try {
      final itemsData = _cartItems.map((c) => {
        'menu_item_id': c.item.id,
        'quantity': c.quantity,
      }).toList();

      final orderData = {
        'restaurant_id': _selectedRestaurantId,
        'delivery_address': address,
        'items': itemsData,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'tax': tax,
        'total': total,
      };

      final order = await _customerRepository.createOrder(orderData);
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
      // Simulate backend checkout plan
      await Future.delayed(const Duration(milliseconds: 500));
      _activeSubscription = plan.title;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void cancelSubscription() {
    _activeSubscription = 'None';
    notifyListeners();
  }
}
