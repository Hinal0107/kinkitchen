import '../../../../models/subscription_plan.dart';

abstract class RestaurantPlansState {}

class RestaurantPlansInitial extends RestaurantPlansState {}

class RestaurantPlansLoading extends RestaurantPlansState {}

class RestaurantPlansLoaded extends RestaurantPlansState {
  final List<SubscriptionPlan> plans;
  RestaurantPlansLoaded(this.plans);
}

class RestaurantPlansOperationSuccess extends RestaurantPlansState {
  final String message;
  RestaurantPlansOperationSuccess(this.message);
}

class RestaurantPlansError extends RestaurantPlansState {
  final String message;
  RestaurantPlansError(this.message);
}
