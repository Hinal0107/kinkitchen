class Order {
  final int id;
  final String orderNumber;
  final int restaurantId;
  final int customerId;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String status; // 'CONFIRMED', 'PREPARING', 'READY', 'OUT_FOR_DELIVERY', 'DELIVERED', 'PENDING'
  final String paymentStatus; // 'PAID', 'PENDING', 'FAILED'
  final String deliveryAddress;
  final String? customerName;
  final String? customerPhone;
  final List<dynamic> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.restaurantId,
    required this.customerId,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.deliveryAddress,
    this.customerName,
    this.customerPhone,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      restaurantId: json['restaurant_id'] as int,
      customerId: json['customer_id'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num? ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] as num? ?? 0.0).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      paymentStatus: json['payment_status'] as String? ?? 'PENDING',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      items: json['items'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'restaurant_id': restaurantId,
      'customer_id': customerId,
      'subtotal': subtotal,
      'tax': tax,
      'delivery_fee': deliveryFee,
      'total': total,
      'status': status,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items,
    };
  }
}
