import 'package:kinkitchen/shared/models/subscription_plan.dart';
import 'package:kinkitchen/shared/models/subscription.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class RestaurantPlansLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  RestaurantPlansLoaded(this.plans);
}

class MySubscriptionsLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;
  MySubscriptionsLoaded(this.subscriptions);
}

class SubscriptionSuccess extends SubscriptionState {
  final Subscription subscription;
  SubscriptionSuccess(this.subscription);
}

class SubscriptionError extends SubscriptionState {
  final String message;
  SubscriptionError(this.message);
}
