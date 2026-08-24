class MenuCategory {
  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final String status; // 'active', 'inactive'
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
    return MenuCategory(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      imageUrl: json['image_url'] as String?,
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
