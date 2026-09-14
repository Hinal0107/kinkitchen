import 'dart:io' show Platform;

class ApiConfig {
  // Live Base URL
  static final String baseUrl = 'https://kingkitchen.addigitalinfo.com/public/index.php/api/v1';
  // Local Base URL
  // static final String baseUrl = Platform.isAndroid 
  //     ? 'http://10.0.2.2:8888/backedn-tiffin/tiffin_backend/public/index.php/api/v1' 
  //     : 'http://localhost:8888/backedn-tiffin/tiffin_backend/public/index.php/api/v1';

  // Live Image Base URL
  static final String imageBaseUrl = 'https://kingkitchen.addigitalinfo.com/public/storage';
  // Local Image Base URL
  // static final String imageBaseUrl = Platform.isAndroid 
  //     ? 'http://10.0.2.2:8888/backedn-tiffin/tiffin_backend/public/storage' 
  //     : 'http://localhost:8888/backedn-tiffin/tiffin_backend/public/storage';

  /// Helper to convert relative or backend-returned image paths into fully qualified URLs
  static String? getFormattedImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    String cleanUrl = url.trim();

    // Handle local device file path schemes
    if (cleanUrl.startsWith('file://') || cleanUrl.startsWith('/data/') || cleanUrl.startsWith('/var/')) {
      return cleanUrl;
    }

    // Extract path after /storage/ if /storage/ exists in URL (strips legacy IP addresses like 192.168.x.x:8000)
    if (cleanUrl.contains('/storage/')) {
      final storagePath = cleanUrl.substring(cleanUrl.indexOf('/storage/') + '/storage/'.length);
      return '$imageBaseUrl/$storagePath';
    }

    if (cleanUrl.startsWith('storage/')) {
      cleanUrl = cleanUrl.substring('storage/'.length);
      return '$imageBaseUrl/$cleanUrl';
    }

    // Replace localhost or 127.0.0.1 with 10.0.2.2 on Android emulator for external URLs
    if (Platform.isAndroid) {
      cleanUrl = cleanUrl
          .replaceAll('http://localhost', 'http://10.0.2.2')
          .replaceAll('http://127.0.0.1', 'http://10.0.2.2')
          .replaceAll('https://localhost', 'https://10.0.2.2')
          .replaceAll('https://127.0.0.1', 'https://10.0.2.2');
    }

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    if (cleanUrl.startsWith('/')) {
      cleanUrl = cleanUrl.substring(1);
    }

    return '$imageBaseUrl/$cleanUrl';
  }

  // --- 🔑 AUTHENTICATION ---
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';

  // --- 🍽️ CUSTOMER — RESTAURANTS & MENU ---
  static const String restaurants = '/restaurants';
  static const String menuItemDetails = '/menu-items'; // + /{id}

  // --- 🗓️ CUSTOMER — DAILY MEALS ---
  static String todayMeal(int restaurantId) => '/restaurants/$restaurantId/today-meal';
  static String tomorrowMeal(int restaurantId) => '/restaurants/$restaurantId/tomorrow-meal';
  static String weeklyMeal(int restaurantId) => '/restaurants/$restaurantId/weekly-meal';
  static String dailyMeals(int restaurantId) => '/restaurants/$restaurantId/daily-meals';
  static String restaurantAddons(int restaurantId) => '/restaurants/$restaurantId/addons';
  static String restaurantTaxes(int restaurantId) => '/restaurants/$restaurantId/taxes';

  // --- 🛒 CUSTOMER — CART ---
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  // --- 📦 CUSTOMER — ORDERS ---
  static const String orders = '/orders';
  static String orderCancel(int orderId) => '/orders/$orderId/cancel';
  static String orderTracking(int orderId) => '/orders/$orderId/tracking';

  // --- 📍 CUSTOMER — ADDRESSES ---
  static const String addresses = '/addresses';

  // --- 🔔 CUSTOMER — SUBSCRIPTIONS ---
  static String restaurantPlans(int restaurantId) => '/restaurants/$restaurantId/subscription-plans';
  static const String subscriptionPlanDetails = '/subscription-plans'; // + /{id}
  static const String subscriptions = '/subscriptions';
  static const String subscriptionAccessStatus = '/subscriptions/access-status';
  static const String termsAndConditions = '/terms-and-conditions';
  static String pauseSubscription(int subId) => '/subscriptions/$subId/pause';
  static String resumeSubscription(int subId) => '/subscriptions/$subId/resume';
  static String cancelSubscription(int subId) => '/subscriptions/$subId/cancel';

  // --- 🏪 RESTAURANT — PORTAL ---
  static const String restaurantProfile = '/restaurant/profile';
  static const String restaurantCategories = '/restaurant/categories';
  static const String restaurantMenuItems = '/restaurant/menu-items';
  static const String restaurantDailyMeals = '/restaurant/daily-meals';
  static const String restaurantSubscriptionPlans = '/restaurant/subscription-plans';
  static const String restaurantOrders = '/restaurant/orders';

  // Restaurant Order Status Updates
  static String confirmOrder(int orderId) => '/restaurant/orders/$orderId/confirm';
  static String preparingOrder(int orderId) => '/restaurant/orders/$orderId/preparing';
  static String readyOrder(int orderId) => '/restaurant/orders/$orderId/ready';
  static String outForDeliveryOrder(int orderId) => '/restaurant/orders/$orderId/out-for-delivery';
  static String deliveredOrder(int orderId) => '/restaurant/orders/$orderId/delivered';
  static String cancelRestaurantOrder(int orderId) => '/restaurant/orders/$orderId/cancel';

  // --- 💳 PAYMENTS ---
  static const String worldpayCreateSession = '/payments/worldpay/create-session';
  static const String worldpaySimulate = '/payments/worldpay/simulate';
  static String refundOrder(int orderId) => '/orders/$orderId/refund';

  // Live Domain
  static final String localDomain = 'https://kingkitchen.addigitalinfo.com';
  // Local Domain
  // static final String localDomain = Platform.isAndroid 
  //     ? 'http://10.0.2.2:8888' 
  //     : 'http://localhost:8888';

  static final String paymentSuccessUrl = '$localDomain/payment-success';
  static final String paymentFailureUrl = '$localDomain/payment-failed';

  // --- 🔔 NOTIFICATIONS & DEVICES ---
  static const String registerFcmToken = '/notifications/token';
  static const String registerDevice = '/devices/register';
  static const String unregisterDevice = '/devices/unregister';
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String markNotificationRead = '/notifications/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
}
