import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinkitchen/shared/repositories/restaurant_repository.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';
import 'restaurant_home_event.dart';
import 'restaurant_home_state.dart';

class RestaurantHomeBloc extends Bloc<RestaurantHomeEvent, RestaurantHomeState> {
  final RestaurantRepository _restaurantRepository;

  RestaurantHomeBloc({RestaurantRepository? restaurantRepository})
      : _restaurantRepository = restaurantRepository ?? RestaurantRepository(),
        super(RestaurantHomeInitial()) {
    on<FetchRestaurantHomeDataEvent>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(FetchRestaurantHomeDataEvent event, Emitter<RestaurantHomeState> emit) async {
    emit(RestaurantHomeLoading());
    try {
      final profile = await _restaurantRepository.getProfile();
      final menuItems = await _restaurantRepository.getMenuItems();
      final categories = await _restaurantRepository.getCategories();

      final addonCat = categories.where((c) => c.name.toLowerCase().contains('add-on') || c.name.toLowerCase().contains('addon')).isNotEmpty
          ? categories.firstWhere((c) => c.name.toLowerCase().contains('add-on') || c.name.toLowerCase().contains('addon'))
          : null;

      final now = DateTime.now();
      final todayDmy = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final tom = now.add(const Duration(days: 1));
      final tomDmy = '${tom.day.toString().padLeft(2, '0')}/${tom.month.toString().padLeft(2, '0')}/${tom.year}';

      final todayMeals = menuItems.where((i) => i.scheduleDate == todayDmy).toList();
      final tomorrowMeals = menuItems.where((i) => i.scheduleDate == tomDmy).toList();
      final List<MenuItem> addons = addonCat != null ? menuItems.where((i) => i.categoryId == addonCat.id).toList() : [];

      emit(RestaurantHomeLoaded(
        profile: profile,
        todayMeals: todayMeals,
        tomorrowMeals: tomorrowMeals,
        addons: addons,
      ));
    } catch (e) {
      emit(RestaurantHomeError(e.toString()));
    }
  }
}
