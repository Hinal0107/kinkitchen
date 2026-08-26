abstract class CustomerMenuEvent {}

class FetchRestaurantMenuEvent extends CustomerMenuEvent {
  final int restaurantId;
  final String? category;
  final String? search;
  FetchRestaurantMenuEvent({required this.restaurantId, this.category, this.search});
}

class FetchDailyMealsEvent extends CustomerMenuEvent {
  final int restaurantId;
  FetchDailyMealsEvent(this.restaurantId);
}
