abstract class RestaurantPlansEvent {}

class FetchRestaurantPlansDataEvent extends RestaurantPlansEvent {}

class CreateSubscriptionPlanEvent extends RestaurantPlansEvent {
  final Map<String, dynamic> body;
  CreateSubscriptionPlanEvent(this.body);
}

class UpdateSubscriptionPlanEvent extends RestaurantPlansEvent {
  final int id;
  final Map<String, dynamic> body;
  UpdateSubscriptionPlanEvent({required this.id, required this.body});
}

class DeleteSubscriptionPlanEvent extends RestaurantPlansEvent {
  final int id;
  DeleteSubscriptionPlanEvent(this.id);
}
