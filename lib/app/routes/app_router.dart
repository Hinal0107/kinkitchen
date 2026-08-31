import 'package:flutter/material.dart';
import '../../modules/auth/presentation/pages/splash_screen.dart';
import '../../modules/auth/presentation/pages/role_selection_screen.dart';
import '../../modules/auth/presentation/pages/customer_login_screen.dart';
import '../../modules/auth/presentation/pages/customer_register_screen.dart';
import '../../modules/auth/presentation/pages/restaurant_login_screen.dart';
import '../../modules/auth/presentation/pages/restaurant_register_screen.dart';
import '../../modules/customer/home/presentation/pages/dashboard_screen.dart';
import '../../modules/customer/subscriptions/presentation/pages/terms_and_conditions_screen.dart';
import '../../modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case RouteNames.customerLogin:
        return MaterialPageRoute(builder: (_) => const CustomerLoginScreen());
      case RouteNames.customerRegister:
        return MaterialPageRoute(builder: (_) => const CustomerRegisterScreen());
      case RouteNames.restaurantLogin:
        return MaterialPageRoute(builder: (_) => const RestaurantLoginScreen());
      case RouteNames.restaurantRegister:
        return MaterialPageRoute(builder: (_) => const RestaurantRegisterScreen());
      case RouteNames.customerDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case RouteNames.restaurantDashboard:
        return MaterialPageRoute(builder: (_) => const RestaurantDashboardScreen());
      case RouteNames.termsAndConditions:
        return MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
