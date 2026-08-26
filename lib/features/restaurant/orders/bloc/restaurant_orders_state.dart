import '../../../../models/order.dart';

abstract class RestaurantOrdersState {}

class RestaurantOrdersInitial extends RestaurantOrdersState {}

class RestaurantOrdersLoading extends RestaurantOrdersState {}

class RestaurantOrdersLoaded extends RestaurantOrdersState {
  final List<Order> orders;
  RestaurantOrdersLoaded(this.orders);
}

class RestaurantOrdersOperationSuccess extends RestaurantOrdersState {
  final String message;
  RestaurantOrdersOperationSuccess(this.message);
}

class RestaurantOrdersError extends RestaurantOrdersState {
  final String message;
  RestaurantOrdersError(this.message);
}
