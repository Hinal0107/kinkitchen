import 'package:flutter/material.dart';
import '../bloc/tiffin_state_provider.dart';
import '../../../../main.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'plans_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class TiffinStateScope extends InheritedNotifier<TiffinStateProvider> {
  const TiffinStateScope({
    super.key,
    required TiffinStateProvider super.notifier,
    required super.child,
  });

  static TiffinStateProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TiffinStateScope>();
    if (scope?.notifier != null) {
      return scope!.notifier!;
    }
    return globalTiffinStateProvider;
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Screens list mapped by tab index
  final List<Widget> _screens = const [
    HomeScreen(),
    MenuScreen(),
    PlansScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFFFF5E00);
    const Color inactiveColor = Color(0xFF9CA3AF);
    final stateProvider = TiffinStateScope.of(context);

    return ListenableBuilder(
      listenable: stateProvider,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', _currentIndex == 0, activeColor, inactiveColor),
                    _buildNavItem(1, Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Menu', _currentIndex == 1, activeColor, inactiveColor),
                    _buildNavItem(2, Icons.calendar_month_outlined, Icons.calendar_month, 'Plans', _currentIndex == 2, activeColor, inactiveColor),
                    _buildNavItem(3, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart', _currentIndex == 3, activeColor, inactiveColor, badgeCount: stateProvider.totalCartCount),
                    _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile', _currentIndex == 4, activeColor, inactiveColor),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
    bool isActive,
    Color activeColor,
    Color inactiveColor, {
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5E00),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
