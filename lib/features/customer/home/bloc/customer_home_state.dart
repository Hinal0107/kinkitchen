import '../../../../models/restaurant.dart';

abstract class CustomerHomeState {}

class CustomerHomeInitial extends CustomerHomeState {}

class CustomerHomeLoading extends CustomerHomeState {}

class CustomerHomeLoaded extends CustomerHomeState {
  final List<Restaurant> restaurants;
  CustomerHomeLoaded(this.restaurants);
}

class CustomerHomeError extends CustomerHomeState {
  final String message;
  CustomerHomeError(this.message);
}
