class MenuItem {
  final int id;
  final int categoryId;
  final int restaurantId;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final String vegType; // 'VEG', 'NON_VEG', 'JAIN'
  final bool availability;
  final String status; // 'active', 'inactive'
  final String? imageUrl;
  final String? scheduleDate;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.vegType,
    required this.availability,
    required this.status,
    this.imageUrl,
    this.scheduleDate,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      restaurantId: json['restaurant_id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unnamed Item',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      discountPrice: (json['discount_price'] as num? ?? 0.0).toDouble(),
      vegType: json['veg_type'] as String? ?? 'VEG',
      availability: (json['availability'] is int) 
          ? (json['availability'] as int) == 1 
          : (json['availability'] as bool? ?? true),
      status: json['status'] as String? ?? 'active',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      scheduleDate: json['schedule_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'veg_type': vegType,
      'availability': availability ? 1 : 0,
      'status': status,
      'image_url': imageUrl,
      'schedule_date': scheduleDate,
    };
  }
}
