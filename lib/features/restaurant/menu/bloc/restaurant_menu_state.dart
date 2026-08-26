import '../../../../models/menu_category.dart';
import '../../../../models/menu_item.dart';

abstract class RestaurantMenuState {}

class RestaurantMenuInitial extends RestaurantMenuState {}

class RestaurantMenuLoading extends RestaurantMenuState {}

class RestaurantMenuLoaded extends RestaurantMenuState {
  final List<MenuCategory> categories;
  final List<MenuItem> menuItems;
  RestaurantMenuLoaded({required this.categories, required this.menuItems});
}

class RestaurantMenuOperationSuccess extends RestaurantMenuState {
  final String message;
  RestaurantMenuOperationSuccess(this.message);
}

class RestaurantMenuError extends RestaurantMenuState {
  final String message;
  RestaurantMenuError(this.message);
}
