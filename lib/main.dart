import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/theme/app_theme.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'core/network/api_client.dart';
import 'shared/services/fcm_service.dart';

import 'modules/auth/presentation/pages/splash_screen.dart';
import 'modules/auth/presentation/pages/role_selection_screen.dart';
import 'modules/auth/presentation/pages/customer_login_screen.dart';
import 'modules/auth/presentation/pages/customer_register_screen.dart';
import 'modules/auth/presentation/pages/restaurant_login_screen.dart';
import 'modules/auth/presentation/pages/restaurant_register_screen.dart';
import 'modules/customer/home/presentation/pages/restaurant_selection_screen.dart';
import 'modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';
import 'modules/customer/subscriptions/presentation/pages/terms_and_conditions_screen.dart';
import 'modules/customer/profile/presentation/pages/notifications_screen.dart';
import 'modules/customer/orders/presentation/pages/order_tracking_screen.dart';
import 'modules/customer/tiffin_state_provider.dart';

// BLoC Imports
import 'modules/auth/presentation/bloc/auth_bloc.dart';
import 'features/customer/home/bloc/customer_home_bloc.dart';
import 'features/customer/menu/bloc/customer_menu_bloc.dart';
import 'features/customer/cart/bloc/cart_bloc.dart';
import 'features/customer/orders/bloc/customer_orders_bloc.dart';
import 'features/customer/address/bloc/address_bloc.dart';
import 'features/customer/subscriptions/bloc/subscription_bloc.dart';
import 'features/restaurant/home/bloc/restaurant_home_bloc.dart';
import 'features/restaurant/menu/bloc/restaurant_menu_bloc.dart';
import 'features/restaurant/plans/bloc/restaurant_plans_bloc.dart';
import 'features/restaurant/orders/bloc/restaurant_orders_bloc.dart';
import 'features/restaurant/profile/bloc/restaurant_profile_bloc.dart';

import 'firebase_options.dart';

final globalTiffinStateProvider = TiffinStateProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<CustomerHomeBloc>(create: (context) => CustomerHomeBloc()),
        BlocProvider<CustomerMenuBloc>(create: (context) => CustomerMenuBloc()),
        BlocProvider<CartBloc>(create: (context) => CartBloc()),
        BlocProvider<CustomerOrdersBloc>(create: (context) => CustomerOrdersBloc()),
        BlocProvider<AddressBloc>(create: (context) => AddressBloc()),
        BlocProvider<SubscriptionBloc>(create: (context) => SubscriptionBloc()),
        BlocProvider<RestaurantHomeBloc>(create: (context) => RestaurantHomeBloc()),
        BlocProvider<RestaurantMenuBloc>(create: (context) => RestaurantMenuBloc()),
        BlocProvider<RestaurantPlansBloc>(create: (context) => RestaurantPlansBloc()),
        BlocProvider<RestaurantOrdersBloc>(create: (context) => RestaurantOrdersBloc()),
        BlocProvider<RestaurantProfileBloc>(create: (context) => RestaurantProfileBloc()),
      ],
      child: TiffinStateScope(
        notifier: globalTiffinStateProvider,
        child: MaterialApp(
          title: 'KinKitchen',
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(isRestaurant: false), // Default Customer theme
          builder: (context, child) {
            return ResponsiveWrapper(child: child ?? const SizedBox());
          },
          initialRoute: '/',
          onGenerateRoute: (settings) {
            WidgetBuilder? builder;
            switch (settings.name) {
              case '/':
                builder = (context) => const SplashScreen();
                break;
              case '/role-selection':
                builder = (context) => const RoleSelectionScreen();
                break;
              case '/customer-login':
                builder = (context) => const CustomerLoginScreen();
                break;
              case '/customer-register':
                builder = (context) => const CustomerRegisterScreen();
                break;
              case '/restaurant-login':
                builder = (context) => const RestaurantLoginScreen();
                break;
              case '/restaurant-register':
                builder = (context) => const RestaurantRegisterScreen();
                break;
              case '/restaurant-selection':
                builder = (context) => const RestaurantSelectionScreen();
                break;
              case '/dashboard':
                builder = (context) => const DashboardScreen();
                break;
              case '/restaurant-dashboard':
                builder = (context) => const RestaurantDashboardScreen();
                break;
              case '/terms-and-conditions':
                builder = (context) => const TermsAndConditionsScreen();
                break;
              case '/notifications':
                builder = (context) => const NotificationsScreen(isRestaurant: false);
                break;
              case '/restaurant-notifications':
                builder = (context) => const NotificationsScreen(isRestaurant: true);
                break;
              default:
                final uri = Uri.parse(settings.name ?? '');
                if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'orders') {
                  final id = int.tryParse(uri.pathSegments[1]);
                  if (id != null) {
                    builder = (context) => OrderTrackingScreen(orderId: id);
                  }
                }
                if (settings.name == '/orders/tracking' && settings.arguments is int) {
                  builder = (context) => OrderTrackingScreen(orderId: settings.arguments as int);
                }
                break;
            }

            if (builder != null) {
              return PageRouteBuilder(
                settings: settings,
                transitionDuration: const Duration(milliseconds: 280),
                reverseTransitionDuration: const Duration(milliseconds: 220),
                pageBuilder: (context, animation, secondaryAnimation) => builder!(context),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  final curveAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                    opacity: curveAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.03, 0),
                        end: Offset.zero,
                      ).animate(curveAnimation),
                      child: child,
                    ),
                  );
                },
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
