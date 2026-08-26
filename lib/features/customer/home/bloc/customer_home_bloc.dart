import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/customer_repository.dart';
import 'customer_home_event.dart';
import 'customer_home_state.dart';

class CustomerHomeBloc extends Bloc<CustomerHomeEvent, CustomerHomeState> {
  final CustomerRepository _customerRepository;

  CustomerHomeBloc({CustomerRepository? customerRepository})
      : _customerRepository = customerRepository ?? CustomerRepository(),
        super(CustomerHomeInitial()) {
    on<FetchRestaurantsEvent>(_onFetchRestaurants);
  }

  Future<void> _onFetchRestaurants(FetchRestaurantsEvent event, Emitter<CustomerHomeState> emit) async {
    emit(CustomerHomeLoading());
    try {
      final restaurants = await _customerRepository.getRestaurants();
      emit(CustomerHomeLoaded(restaurants));
    } catch (e) {
      emit(CustomerHomeError(e.toString()));
    }
  }
}
