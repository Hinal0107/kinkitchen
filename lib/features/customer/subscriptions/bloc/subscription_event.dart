abstract class SubscriptionEvent {}

class FetchRestaurantPlansEvent extends SubscriptionEvent {
  final int restaurantId;
  FetchRestaurantPlansEvent(this.restaurantId);
}

class SubscribeToPlanEvent extends SubscriptionEvent {
  final int restaurantId;
  final int planId;
  final String startDate;
  final int addressId;
  final bool autoRenew;
  SubscribeToPlanEvent({
    required this.restaurantId,
    required this.planId,
    required this.startDate,
    required this.addressId,
    this.autoRenew = true,
  });
}

class FetchMySubscriptionsEvent extends SubscriptionEvent {}

class PauseSubscriptionEvent extends SubscriptionEvent {
  final int subscriptionId;
  PauseSubscriptionEvent(this.subscriptionId);
}

class ResumeSubscriptionEvent extends SubscriptionEvent {
  final int subscriptionId;
  ResumeSubscriptionEvent(this.subscriptionId);
}

class CancelSubscriptionEvent extends SubscriptionEvent {
  final int subscriptionId;
  CancelSubscriptionEvent(this.subscriptionId);
}
