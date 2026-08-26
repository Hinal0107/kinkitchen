import 'dart:io';

abstract class RestaurantMenuEvent {}

class FetchRestaurantMenuDataEvent extends RestaurantMenuEvent {
  final String? category;
  final String? search;
  FetchRestaurantMenuDataEvent({this.category, this.search});
}

class CreateMenuItemEvent extends RestaurantMenuEvent {
  final Map<String, String> fields;
  final File? image;
  CreateMenuItemEvent({required this.fields, this.image});
}

class UpdateMenuItemEvent extends RestaurantMenuEvent {
  final int id;
  final Map<String, String> fields;
  final File? image;
  UpdateMenuItemEvent({required this.id, required this.fields, this.image});
}

class DeleteMenuItemEvent extends RestaurantMenuEvent {
  final int id;
  DeleteMenuItemEvent(this.id);
}

class CreateCategoryEvent extends RestaurantMenuEvent {
  final String name;
  final String description;
  final String status;
  CreateCategoryEvent({required this.name, required this.description, required this.status});
}

class DeleteCategoryEvent extends RestaurantMenuEvent {
  final int id;
  DeleteCategoryEvent(this.id);
}
