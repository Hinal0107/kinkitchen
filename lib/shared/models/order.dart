import 'cart_item.dart';

class Order {
  final int id;
  final String orderNumber;
  final int userId;
  final int restaurantId;
  final int addressId;
  final String status;
  final String paymentStatus;
  final String? deliveryStatus;
  final String? deliveryOtp;
  final bool otpRevealed;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final String? deliveryNotes;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final List<CartItem> items;
  final String createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.restaurantId,
    required this.addressId,
    required this.status,
    required this.paymentStatus,
    this.deliveryStatus,
    this.deliveryOtp,
    this.otpRevealed = false,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    this.deliveryNotes,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double toDouble(dynamic val) {
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    bool toBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemList = rawItems.map((i) => CartItem.fromJson(i as Map<String, dynamic>)).toList();

    final userObj = json['user'] as Map<String, dynamic>? ?? json['customer'] as Map<String, dynamic>?;
    final addressObj = json['address'] as Map<String, dynamic>?;

    return Order(
      id: toInt(json['id']),
      orderNumber: json['order_number']?.toString() ?? json['id']?.toString() ?? '',
      userId: toInt(json['user_id'] ?? json['customer_id']),
      restaurantId: toInt(json['restaurant_id']),
      addressId: toInt(json['address_id']),
      status: json['order_status']?.toString() ?? json['status']?.toString() ?? 'PENDING',
      paymentStatus: json['payment_status']?.toString() ?? 'PENDING',
      deliveryStatus: json['delivery_status']?.toString(),
      deliveryOtp: json['delivery_otp']?.toString(),
      otpRevealed: toBool(json['otp_revealed']),
      subtotal: toDouble(json['subtotal']),
      deliveryFee: toDouble(json['delivery_fee']),
      tax: toDouble(json['tax']),
      total: toDouble(json['total'] ?? json['total_amount']),
      deliveryNotes: json['delivery_notes']?.toString() ?? json['notes']?.toString(),
      customerName: userObj?['name']?.toString() ?? json['customer_name']?.toString() ?? 'Customer',
      customerPhone: userObj?['phone']?.toString() ?? json['customer_phone']?.toString() ?? '',
      deliveryAddress: addressObj?['line1']?.toString() ?? json['delivery_address']?.toString() ?? 'Delivery Address',
      items: itemList,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'address_id': addressId,
      'status': status,
      'payment_status': paymentStatus,
      'delivery_status': deliveryStatus,
      'delivery_otp': deliveryOtp,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'tax': tax,
      'total': total,
      'delivery_notes': deliveryNotes,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt,
    };
  }
}
