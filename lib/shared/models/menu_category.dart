class MenuCategory {
  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final String status;
  final String? imageUrl;

  MenuCategory({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.status,
    this.imageUrl,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return MenuCategory(
      id: toInt(json['id']),
      restaurantId: toInt(json['restaurant_id']),
      name: json['name']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'status': status,
      'image_url': imageUrl,
    };
  }
}
