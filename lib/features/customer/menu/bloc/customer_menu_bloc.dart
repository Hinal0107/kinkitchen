import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinkitchen/shared/repositories/customer_repository.dart';
import 'customer_menu_event.dart';
import 'customer_menu_state.dart';

class CustomerMenuBloc extends Bloc<CustomerMenuEvent, CustomerMenuState> {
  final CustomerRepository _customerRepository;

  CustomerMenuBloc({CustomerRepository? customerRepository})
      : _customerRepository = customerRepository ?? CustomerRepository(),
        super(CustomerMenuInitial()) {
    on<FetchRestaurantMenuEvent>(_onFetchRestaurantMenu);
  }

  Future<void> _onFetchRestaurantMenu(FetchRestaurantMenuEvent event, Emitter<CustomerMenuState> emit) async {
    emit(CustomerMenuLoading());
    try {
      final categories = await _customerRepository.getRestaurantCategories(event.restaurantId);
      final menuItems = await _customerRepository.getRestaurantMenu(event.restaurantId, category: event.category, search: event.search);
      final todayMeals = await _customerRepository.getTodayMeal(event.restaurantId);
      final tomorrowMeals = await _customerRepository.getTomorrowMeal(event.restaurantId);
      final addons = await _customerRepository.getRestaurantAddons(event.restaurantId);

      emit(CustomerMenuLoaded(
        categories: categories,
        menuItems: menuItems,
        todayMeals: todayMeals,
        tomorrowMeals: tomorrowMeals,
        addons: addons,
      ));
    } catch (e) {
      emit(CustomerMenuError(e.toString()));
    }
  }
}
