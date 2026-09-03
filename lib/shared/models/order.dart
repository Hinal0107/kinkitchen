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
  final double subscriptionAmount;
  final double additionalMealAmount;
  final double addonAmount;
  final double discountAmount;
  final double paidAmount;
  final double remainingAmount;
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
    this.subscriptionAmount = 0.0,
    this.additionalMealAmount = 0.0,
    this.addonAmount = 0.0,
    this.discountAmount = 0.0,
    this.paidAmount = 0.0,
    this.remainingAmount = 0.0,
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

    final double totalVal = toDouble(json['total'] ?? json['total_amount']);
    final double subAmount = toDouble(json['subscription_amount'] ?? json['subscription_coverage']);
    final double paidVal = json['paid_amount'] != null
        ? toDouble(json['paid_amount'])
        : (json['customer_paid'] != null ? toDouble(json['customer_paid']) : (totalVal - subAmount).clamp(0.0, 999999.0));

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
      total: totalVal,
      subscriptionAmount: subAmount,
      additionalMealAmount: toDouble(json['additional_meal_amount']),
      addonAmount: toDouble(json['addon_amount']),
      discountAmount: toDouble(json['discount_amount']),
      paidAmount: paidVal,
      remainingAmount: toDouble(json['remaining_amount']),
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
      'subscription_amount': subscriptionAmount,
      'additional_meal_amount': additionalMealAmount,
      'addon_amount': addonAmount,
      'discount_amount': discountAmount,
      'total_amount': total,
      'delivery_notes': deliveryNotes,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt,
    };
  }
}

class OrderStatus {
  static const String pendingPayment = 'PENDING_PAYMENT';
  static const String confirmed = 'CONFIRMED';
  static const String preparing = 'PREPARING';
  static const String ready = 'READY';
  static const String completed = 'COMPLETED';
  static const String cancelled = 'CANCELLED';
}

class DeliveryStatus {
  static const String pending = 'PENDING';
  static const String outForDelivery = 'OUT_FOR_DELIVERY';
  static const String delivered = 'DELIVERED';
}

class OrderTrackingTimelineStep {
  final String status;
  final String timestamp;

  OrderTrackingTimelineStep({
    required this.status,
    required this.timestamp,
  });

  factory OrderTrackingTimelineStep.fromJson(Map<String, dynamic> json) {
    return OrderTrackingTimelineStep(
      status: json['status']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'timestamp': timestamp,
      };
}

class OrderTrackingData {
  final int orderId;
  final String orderNumber;
  final String orderStatus;
  final String deliveryStatus;
  final String? deliveryOtp;
  final String restaurantName;
  final String scheduledDate;
  final List<OrderTrackingTimelineStep> timeline;

  OrderTrackingData({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.deliveryStatus,
    this.deliveryOtp,
    required this.restaurantName,
    required this.scheduledDate,
    required this.timeline,
  });

  factory OrderTrackingData.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final rawTimeline = json['timeline'] as List<dynamic>? ?? [];
    final timelineList = rawTimeline
        .map((t) => OrderTrackingTimelineStep.fromJson(t as Map<String, dynamic>))
        .toList();

    return OrderTrackingData(
      orderId: toInt(json['order_id'] ?? json['id']),
      orderNumber: json['order_number']?.toString() ?? '',
      orderStatus: json['order_status']?.toString() ?? json['status']?.toString() ?? OrderStatus.pendingPayment,
      deliveryStatus: json['delivery_status']?.toString() ?? DeliveryStatus.pending,
      deliveryOtp: json['delivery_otp']?.toString(),
      restaurantName: json['restaurant_name']?.toString() ?? 'Kin Kitchen',
      scheduledDate: json['scheduled_date']?.toString() ?? '',
      timeline: timelineList,
    );
  }
}

