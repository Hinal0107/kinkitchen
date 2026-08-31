import 'package:kinkitchen/shared/models/menu_category.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';

abstract class CustomerMenuState {}

class CustomerMenuInitial extends CustomerMenuState {}

class CustomerMenuLoading extends CustomerMenuState {}

class CustomerMenuLoaded extends CustomerMenuState {
  final List<MenuCategory> categories;
  final List<MenuItem> menuItems;
  final List<MenuItem> todayMeals;
  final List<MenuItem> tomorrowMeals;
  final List<MenuItem> addons;

  CustomerMenuLoaded({
    required this.categories,
    required this.menuItems,
    required this.todayMeals,
    required this.tomorrowMeals,
    required this.addons,
  });
}

class CustomerMenuError extends CustomerMenuState {
  final String message;
  CustomerMenuError(this.message);
}
