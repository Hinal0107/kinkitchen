import 'package:kinkitchen/app/constants/api_constants.dart';
import 'package:kinkitchen/core/network/api_client.dart';
import 'package:kinkitchen/shared/models/order.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // --- 🛒 CUSTOMER ORDERS ---

  // 1. Place Order
  Future<Order> placeOrder({
    required int restaurantId,
    required int addressId,
    String? deliveryNotes,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.orders,
      body: {
        'restaurant_id': restaurantId,
        'address_id': addressId,
        if (deliveryNotes != null) 'delivery_notes': deliveryNotes,
        'items': items,
      },
    );
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  // 2. List Customer Orders
  Future<List<Order>> getMyOrders({String? status, int limit = 20}) async {
    final queryParams = {
      if (status != null && status.isNotEmpty) 'status': status,
      'limit': limit.toString(),
    };
    final response = await _apiClient.get(ApiConfig.orders, queryParameters: queryParams);
    final data = response['data'] ?? response['orders'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 3. Get Order Details
  Future<Order> getOrderDetails(int orderId) async {
    final response = await _apiClient.get('${ApiConfig.orders}/$orderId');
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  // 4. Cancel Order (Customer)
  Future<Order> cancelOrder(int orderId, String reason) async {
    final response = await _apiClient.post(
      ApiConfig.orderCancel(orderId),
      body: {'reason': reason},
    );
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  // 5. Track Order Timeline
  Future<Map<String, dynamic>> getOrderTracking(int orderId) async {
    final response = await _apiClient.get(ApiConfig.orderTracking(orderId));
    return (response['data'] ?? response) as Map<String, dynamic>;
  }

  // 5b. Simulate Worldpay Payment (Dev/Sandbox)
  Future<Map<String, dynamic>> simulateWorldpayPayment({
    required String orderNumber,
    String status = 'PAID',
  }) async {
    final response = await _apiClient.post(
      ApiConfig.worldpaySimulate,
      body: {
        'order_number': orderNumber,
        'status': status,
      },
    );
    return (response['data'] ?? response) as Map<String, dynamic>;
  }

  // --- 🏪 RESTAURANT ORDERS ---

  // 6. List Restaurant Orders
  Future<List<Order>> getRestaurantOrders({String? status, int limit = 20}) async {
    final queryParams = {
      if (status != null && status.isNotEmpty) 'status': status,
      'limit': limit.toString(),
    };
    final response = await _apiClient.get(ApiConfig.restaurantOrders, queryParameters: queryParams);
    final data = response['data'] ?? response['orders'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 7. Confirm Order
  Future<Order> confirmOrder(int orderId) async {
    final response = await _apiClient.post(ApiConfig.confirmOrder(orderId));
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  // 8. Mark as Preparing
  Future<Order> markPreparing(int orderId) async {
    final response = await _apiClient.post(ApiConfig.preparingOrder(orderId));
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  // 9. Mark as Ready
  Future<Order> markReady(int orderId) async {
    final response = await _apiClient.post(ApiConfig.readyOrder(orderId));
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  // 10. Mark Out for Delivery
  Future<Order> markOutForDelivery(int orderId) async {
    final response = await _apiClient.post(ApiConfig.outForDeliveryOrder(orderId));
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  // 11. Mark as Delivered
  Future<Order> markDelivered(int orderId, String deliveryOtp) async {
    final response = await _apiClient.post(
      ApiConfig.deliveredOrder(orderId),
      body: {'delivery_otp': deliveryOtp},
    );
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }

  // 12. Cancel Order (Restaurant)
  Future<Order> cancelRestaurantOrder(int orderId, String reason) async {
    final response = await _apiClient.post(
      ApiConfig.cancelRestaurantOrder(orderId),
      body: {'reason': reason},
    );
    final data = response['data'] ?? response['order'] ?? response;
    return Order.fromJson(data as Map<String, dynamic>);
  }
}
