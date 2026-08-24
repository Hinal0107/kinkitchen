import 'package:flutter/material.dart';
import '../../../../core/widgets/food_image.dart';
import '../../../../services/auth_service.dart';
import '../bloc/restaurant_state_provider.dart';
import 'restaurant_dashboard_screen.dart';

class RestaurantProfileScreen extends StatelessWidget {
  const RestaurantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = RestaurantStateScope.of(context);
    const Color merchantGreen = Color(0xFF00A859);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Restaurant Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Avatar
                  const FoodImage(
                    title: 'avatar',
                    width: 72,
                    height: 72,
                    borderRadius: 36,
                  ),
                  const SizedBox(width: 16),
                  
                  // Text details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ABC Restaurant',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'John Doe (Owner)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Details list rows
                        _buildContactRow(Icons.mail_outline, 'contact@abcrestaurant.com'),
                        const SizedBox(height: 6),
                        _buildContactRow(Icons.phone_outlined, '+1 (555) 123-4567'),
                        const SizedBox(height: 6),
                        _buildContactRow(Icons.location_on_outlined, '123 Culinary Way, Food District, NY 10011'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. Restaurant Management Options List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
              ),
              child: Column(
                children: [
                  _buildManagementTile(
                    context,
                    icon: Icons.today_outlined,
                    iconColor: merchantGreen,
                    title: 'Manage Today\'s Meal',
                    subtitle: 'Create and manage today\'s available meal',
                    tabIndex: 3,
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  
                  _buildManagementTile(
                    context,
                    icon: Icons.next_plan_outlined,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Manage Tomorrow\'s Meal',
                    subtitle: 'Create and manage tomorrow\'s meal',
                    tabIndex: 3,
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildManagementTile(
                    context,
                    icon: Icons.restaurant_menu_outlined,
                    iconColor: const Color(0xFFFF9F1C),
                    title: 'Manage Menu',
                    subtitle: 'Manage menu items, categories, and add-ons',
                    tabIndex: 1,
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildManagementTile(
                    context,
                    icon: Icons.card_membership_outlined,
                    iconColor: Colors.purple,
                    title: 'Manage Subscription Plans',
                    tabIndex: 2,
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  // Logout tile
                  ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text('Are you sure you want to log out of the Merchant Portal?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await AuthService().logout();
                                if (!context.mounted) return;
                                Navigator.pop(context); // Close dialog
                                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                              },
                              child: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444))),
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required int tabIndex,
  }) {
    return ListTile(
      onTap: () {
        // Navigate programmatically to selected tab
        context.findAncestorStateOfType<RestaurantDashboardScreenState>()?.setTab(tabIndex);
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
