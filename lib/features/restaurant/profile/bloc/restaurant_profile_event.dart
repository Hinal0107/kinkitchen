import 'dart:io';

abstract class RestaurantProfileEvent {}

class FetchRestaurantProfileEvent extends RestaurantProfileEvent {}

class UpdateRestaurantProfileEvent extends RestaurantProfileEvent {
  final Map<String, String> fields;
  final File? logo;
  UpdateRestaurantProfileEvent({required this.fields, this.logo});
}
