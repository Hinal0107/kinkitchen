import '../../../../models/restaurant.dart';

abstract class RestaurantProfileState {}

class RestaurantProfileInitial extends RestaurantProfileState {}

class RestaurantProfileLoading extends RestaurantProfileState {}

class RestaurantProfileLoaded extends RestaurantProfileState {
  final Restaurant profile;
  RestaurantProfileLoaded(this.profile);
}

class RestaurantProfileOperationSuccess extends RestaurantProfileState {
  final Restaurant profile;
  final String message;
  RestaurantProfileOperationSuccess({required this.profile, required this.message});
}

class RestaurantProfileError extends RestaurantProfileState {
  final String message;
  RestaurantProfileError(this.message);
}
