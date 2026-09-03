import 'package:kinkitchen/shared/models/order.dart';

abstract class CustomerOrdersState {}

class CustomerOrdersInitial extends CustomerOrdersState {}

class CustomerOrdersLoading extends CustomerOrdersState {}

class CustomerOrdersLoaded extends CustomerOrdersState {
  final List<Order> orders;
  CustomerOrdersLoaded(this.orders);
}

class OrderPlacedSuccess extends CustomerOrdersState {
  final Order order;
  OrderPlacedSuccess(this.order);
}

class OrderDetailsLoaded extends CustomerOrdersState {
  final Order order;
  OrderDetailsLoaded(this.order);
}

class OrderTrackingLoaded extends CustomerOrdersState {
  final OrderTrackingData trackingData;
  OrderTrackingLoaded(this.trackingData);
}

class CustomerOrdersError extends CustomerOrdersState {
  final String message;
  CustomerOrdersError(this.message);
}
