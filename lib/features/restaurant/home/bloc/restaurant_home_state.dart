import 'package:kinkitchen/shared/models/restaurant.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';

abstract class RestaurantHomeState {}

class RestaurantHomeInitial extends RestaurantHomeState {}

class RestaurantHomeLoading extends RestaurantHomeState {}

class RestaurantHomeLoaded extends RestaurantHomeState {
  final Restaurant? profile;
  final List<MenuItem> todayMeals;
  final List<MenuItem> tomorrowMeals;
  final List<MenuItem> addons;

  RestaurantHomeLoaded({
    this.profile,
    required this.todayMeals,
    required this.tomorrowMeals,
    required this.addons,
  });
}

class RestaurantHomeError extends RestaurantHomeState {
  final String message;
  RestaurantHomeError(this.message);
}
