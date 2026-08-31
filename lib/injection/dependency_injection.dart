import 'package:flutter/material.dart';
import 'package:kinkitchen/main.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';

class DependencyInjection {
  static Widget setupProviders({required Widget child}) {
    return TiffinStateScope(
      notifier: globalTiffinStateProvider,
      child: RestaurantStateScope(
        notifier: globalRestaurantStateProvider,
        child: child,
      ),
    );
  }
}
