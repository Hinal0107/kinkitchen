import 'package:flutter/material.dart';
import '../bloc/restaurant_state_provider.dart';
import 'restaurant_home_screen.dart';
import 'restaurant_menu_screen.dart';
import 'restaurant_plans_screen.dart';
import 'restaurant_orders_screen.dart';
import 'restaurant_profile_screen.dart';

class RestaurantStateScope extends InheritedNotifier<RestaurantStateProvider> {
  const RestaurantStateScope({
    super.key,
    required RestaurantStateProvider super.notifier,
    required super.child,
  });

  static RestaurantStateProvider of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final scope = context.dependOnInheritedWidgetOfExactType<RestaurantStateScope>();
      assert(scope != null, 'No RestaurantStateScope found in context');
      return scope!.notifier!;
    } else {
      final element = context.getElementForInheritedWidgetOfExactType<RestaurantStateScope>();
      assert(element != null, 'No RestaurantStateScope found in context');
      return (element!.widget as RestaurantStateScope).notifier!;
    }
  }
}

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => RestaurantDashboardScreenState();
}

class RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  int _currentIndex = 0;
  late final RestaurantStateProvider _stateProvider;

  @override
  void initState() {
    super.initState();
    _stateProvider = RestaurantStateProvider();
  }

  @override
  void dispose() {
    _stateProvider.dispose();
    super.dispose();
  }

  // Set active tab programmatically
  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const RestaurantHomeScreen(),
    const RestaurantMenuScreen(),
    const RestaurantPlansScreen(),
    const RestaurantOrdersScreen(),
    const RestaurantProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF00A859); // Green theme for merchant
    const Color inactiveColor = Color(0xFF9CA3AF);

    return RestaurantStateScope(
      notifier: _stateProvider,
      child: ListenableBuilder(
        listenable: _stateProvider,
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
                      _buildNavItem(3, Icons.receipt_long_outlined, Icons.receipt_long, 'Orders', _currentIndex == 3, activeColor, inactiveColor),
                      _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile', _currentIndex == 4, activeColor, inactiveColor),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
    bool isActive,
    Color activeColor,
    Color inactiveColor,
  ) {
    return GestureDetector(
      onTap: () => setTab(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
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
