import 'package:flutter/material.dart';

class FoodImage extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final double borderRadius;

  const FoodImage({
    super.key,
    required this.title,
    this.width = double.infinity,
    this.height = 160,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final String normalizedTitle = title.toLowerCase();
    
    // Choose theme colors based on item title
    List<Color> gradientColors;
    IconData icon;
    String shortcutText;

    if (normalizedTitle.contains('thali')) {
      // Veg/Deluxe Thali
      gradientColors = [const Color(0xFFFF9F1C), const Color(0xFFFF4000)];
      icon = Icons.restaurant_menu_outlined;
      shortcutText = 'Thali';
    } else if (normalizedTitle.contains('chicken')) {
      // Grilled Chicken Bowl
      gradientColors = [const Color(0xFFE29578), const Color(0xFFDD6B55)];
      icon = Icons.lunch_dining_outlined;
      shortcutText = 'Bowl';
    } else if (normalizedTitle.contains('paneer') || normalizedTitle.contains('salad')) {
      // Palak Paneer / Veg
      gradientColors = [const Color(0xFF90BE6D), const Color(0xFF43AA8B)];
      icon = Icons.eco_outlined;
      shortcutText = 'Green';
    } else if (normalizedTitle.contains('wedges') || normalizedTitle.contains('rotis')) {
      // Sides / Wedges
      gradientColors = [const Color(0xFFF9C74F), const Color(0xFFF3722C)];
      icon = Icons.bakery_dining_outlined;
      shortcutText = 'Sides';
    } else if (normalizedTitle.contains('chaas') || normalizedTitle.contains('drink') || normalizedTitle.contains('jamun')) {
      // Drinks or Desserts
      gradientColors = [const Color(0xFF4EA8DE), const Color(0xFF560BAD)];
      icon = Icons.local_drink_outlined;
      shortcutText = 'Sweet';
    } else if (normalizedTitle.contains('avatar') || normalizedTitle.contains('john')) {
      // User Avatar
      gradientColors = [const Color(0xFF7209B7), const Color(0xFFF72585)];
      icon = Icons.person_outline;
      shortcutText = 'User';
    } else {
      // Fallback Default
      gradientColors = [const Color(0xFFFF5E00), const Color(0xFFFF9E00)];
      icon = Icons.fastfood_outlined;
      shortcutText = 'Meal';
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Decorative Abstract Shapes
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: width * 0.45 > 80 ? 80 : width * 0.45,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Central Glassmorphic Card
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: height * 0.25 > 40 ? 40 : height * 0.25,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortcutText.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
