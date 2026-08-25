import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'core/network/api_client.dart';
import 'services/fcm_service.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';
import 'features/auth/presentation/screens/customer_login_screen.dart';
import 'features/auth/presentation/screens/customer_register_screen.dart';
import 'features/auth/presentation/screens/restaurant_login_screen.dart';
import 'features/auth/presentation/screens/restaurant_register_screen.dart';
import 'features/tiffin/presentation/screens/dashboard_screen.dart';
import 'features/tiffin/presentation/screens/restaurant_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize FCM Push Notifications
  try {
    final fcmService = FcmService();
    await fcmService.initialize();
  } catch (e) {
    debugPrint('Error initializing FCM: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KinKitchen',
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(isRestaurant: false), // Default Customer theme
      // The builder wraps all navigation routes in our responsive simulator shell
      builder: (context, child) {
        return ResponsiveWrapper(child: child ?? const SizedBox());
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/customer-login': (context) => const CustomerLoginScreen(),
        '/customer-register': (context) => const CustomerRegisterScreen(),
        '/restaurant-login': (context) => const RestaurantLoginScreen(),
        '/restaurant-register': (context) => const RestaurantRegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/restaurant-dashboard': (context) => const RestaurantDashboardScreen(),
      },
    );
  }
}
