import 'package:flutter/material.dart';
import '../../../../core/widgets/food_image.dart';
import '../../../../services/auth_service.dart';
import '../bloc/tiffin_state_provider.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color customerOrange = Color(0xFFFF5E00);
    const Color restaurantGreen = Color(0xFF00A859);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF4B5563)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings opened')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. User Info Card
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
                children: [
                  // Avatar
                  Stack(
                    children: [
                      const FoodImage(
                        title: 'avatar',
                        width: 72,
                        height: 72,
                        borderRadius: 36,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: customerOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Text details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '+1 555 000 0000',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Premium Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: customerOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Premium Member',
                            style: TextStyle(
                              color: customerOrange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. Options List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
              ),
              child: Column(
                children: [
                  // Subscriptions Option (Dynamic subtitle matching active state)
                  _buildProfileTile(
                    icon: Icons.calendar_month_outlined,
                    iconColor: restaurantGreen,
                    title: 'My Subscriptions',
                    subtitle: state.activeSubscription == 'None'
                        ? 'Active: None'
                        : 'Active: ${state.activeSubscription}',
                    onTap: () {
                      // Switch to plans screen (index 2)
                      context.findAncestorStateOfType<DashboardScreenState>()?.setTab(2);
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  
                  _buildProfileTile(
                    icon: Icons.history,
                    iconColor: customerOrange,
                    title: 'Order History',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildProfileTile(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.blue,
                    title: 'Delivery Addresses',
                    subtitle: '123 Main Street, Apt 4B',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildProfileTile(
                    icon: Icons.payment_outlined,
                    iconColor: Colors.purple,
                    title: 'Payment Methods',
                    subtitle: 'Visa ending in 4242',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  _buildProfileTile(
                    icon: Icons.help_outline,
                    iconColor: Colors.teal,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  // Logout tile (red color)
                  _buildProfileTile(
                    icon: Icons.logout,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Logout',
                    titleColor: const Color(0xFFEF4444),
                    showChevron: false,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text('Are you sure you want to log out of KinKitchen?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                state.clearCart();
                                state.cancelSubscription();
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color titleColor = const Color(0xFF1F2937),
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
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
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            )
          : null,
      trailing: showChevron
          ? const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
