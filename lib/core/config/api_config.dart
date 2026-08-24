import 'dart:io' show Platform;

class ApiConfig {
  static final String baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8888/backedn-tiffin/tiffin_backend/public/index.php/api/v1' 
      : 'http://localhost:8888/backedn-tiffin/tiffin_backend/public/index.php/api/v1';

  static final String imageBaseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8888/backedn-tiffin/tiffin_backend/public/storage' 
      : 'http://localhost:8888/backedn-tiffin/tiffin_backend/public/storage';

  // Authentication
  static const String me = '/auth/me';
  static const String login = '/auth/login';

  // Restaurant Portal Endpoints
  static const String restaurantProfile = '/restaurant/profile';
  static const String restaurantCategories = '/restaurant/categories';
  static const String restaurantMenuItems = '/restaurant/menu-items';
  static const String restaurantPlans = '/restaurant/subscription-plans';
  static const String restaurantOrders = '/restaurant/orders';
  static const String restaurantCustomers = '/restaurant/customers';

  // Customer Portal Endpoints
  static const String customerRestaurants = '/restaurants';
  static const String customerOrders = '/orders';
  static const String cartItems = '/cart/items';
}
