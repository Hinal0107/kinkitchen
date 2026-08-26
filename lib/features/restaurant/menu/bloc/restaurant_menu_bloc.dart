import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/restaurant_repository.dart';
import 'restaurant_menu_event.dart';
import 'restaurant_menu_state.dart';

class RestaurantMenuBloc extends Bloc<RestaurantMenuEvent, RestaurantMenuState> {
  final RestaurantRepository _restaurantRepository;

  RestaurantMenuBloc({RestaurantRepository? restaurantRepository})
      : _restaurantRepository = restaurantRepository ?? RestaurantRepository(),
        super(RestaurantMenuInitial()) {
    on<FetchRestaurantMenuDataEvent>(_onFetchMenuData);
    on<CreateMenuItemEvent>(_onCreateMenuItem);
    on<UpdateMenuItemEvent>(_onUpdateMenuItem);
    on<DeleteMenuItemEvent>(_onDeleteMenuItem);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onFetchMenuData(FetchRestaurantMenuDataEvent event, Emitter<RestaurantMenuState> emit) async {
    emit(RestaurantMenuLoading());
    try {
      final categories = await _restaurantRepository.getCategories();
      final menuItems = await _restaurantRepository.getMenuItems(category: event.category, search: event.search);
      emit(RestaurantMenuLoaded(categories: categories, menuItems: menuItems));
    } catch (e) {
      emit(RestaurantMenuError(e.toString()));
    }
  }

  Future<void> _onCreateMenuItem(CreateMenuItemEvent event, Emitter<RestaurantMenuState> emit) async {
    try {
      await _restaurantRepository.createMenuItem(event.fields, image: event.image);
      emit(RestaurantMenuOperationSuccess('Menu item created successfully!'));
      add(FetchRestaurantMenuDataEvent());
    } catch (e) {
      emit(RestaurantMenuError(e.toString()));
    }
  }

  Future<void> _onUpdateMenuItem(UpdateMenuItemEvent event, Emitter<RestaurantMenuState> emit) async {
    try {
      await _restaurantRepository.updateMenuItem(event.id, event.fields, image: event.image);
      emit(RestaurantMenuOperationSuccess('Menu item updated successfully!'));
      add(FetchRestaurantMenuDataEvent());
    } catch (e) {
      emit(RestaurantMenuError(e.toString()));
    }
  }

  Future<void> _onDeleteMenuItem(DeleteMenuItemEvent event, Emitter<RestaurantMenuState> emit) async {
    try {
      await _restaurantRepository.deleteMenuItem(event.id);
      emit(RestaurantMenuOperationSuccess('Menu item deleted successfully!'));
      add(FetchRestaurantMenuDataEvent());
    } catch (e) {
      emit(RestaurantMenuError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(CreateCategoryEvent event, Emitter<RestaurantMenuState> emit) async {
    try {
      await _restaurantRepository.createCategory(event.name, event.description, event.status);
      emit(RestaurantMenuOperationSuccess('Category created successfully!'));
      add(FetchRestaurantMenuDataEvent());
    } catch (e) {
      emit(RestaurantMenuError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<RestaurantMenuState> emit) async {
    try {
      await _restaurantRepository.deleteCategory(event.id);
      emit(RestaurantMenuOperationSuccess('Category deleted successfully!'));
      add(FetchRestaurantMenuDataEvent());
    } catch (e) {
      emit(RestaurantMenuError(e.toString()));
    }
  }
}
