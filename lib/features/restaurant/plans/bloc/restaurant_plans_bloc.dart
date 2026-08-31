import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinkitchen/shared/repositories/restaurant_repository.dart';
import 'restaurant_plans_event.dart';
import 'restaurant_plans_state.dart';

class RestaurantPlansBloc extends Bloc<RestaurantPlansEvent, RestaurantPlansState> {
  final RestaurantRepository _restaurantRepository;

  RestaurantPlansBloc({RestaurantRepository? restaurantRepository})
      : _restaurantRepository = restaurantRepository ?? RestaurantRepository(),
        super(RestaurantPlansInitial()) {
    on<FetchRestaurantPlansDataEvent>(_onFetchPlansData);
    on<CreateSubscriptionPlanEvent>(_onCreatePlan);
    on<UpdateSubscriptionPlanEvent>(_onUpdatePlan);
    on<DeleteSubscriptionPlanEvent>(_onDeletePlan);
  }

  Future<void> _onFetchPlansData(FetchRestaurantPlansDataEvent event, Emitter<RestaurantPlansState> emit) async {
    emit(RestaurantPlansLoading());
    try {
      final plans = await _restaurantRepository.getPlans();
      emit(RestaurantPlansLoaded(plans));
    } catch (e) {
      emit(RestaurantPlansError(e.toString()));
    }
  }

  Future<void> _onCreatePlan(CreateSubscriptionPlanEvent event, Emitter<RestaurantPlansState> emit) async {
    try {
      await _restaurantRepository.createPlan(event.body);
      emit(RestaurantPlansOperationSuccess('Subscription plan created successfully!'));
      add(FetchRestaurantPlansDataEvent());
    } catch (e) {
      emit(RestaurantPlansError(e.toString()));
    }
  }

  Future<void> _onUpdatePlan(UpdateSubscriptionPlanEvent event, Emitter<RestaurantPlansState> emit) async {
    try {
      await _restaurantRepository.updatePlan(event.id, event.body);
      emit(RestaurantPlansOperationSuccess('Subscription plan updated successfully!'));
      add(FetchRestaurantPlansDataEvent());
    } catch (e) {
      emit(RestaurantPlansError(e.toString()));
    }
  }

  Future<void> _onDeletePlan(DeleteSubscriptionPlanEvent event, Emitter<RestaurantPlansState> emit) async {
    try {
      await _restaurantRepository.deletePlan(event.id);
      emit(RestaurantPlansOperationSuccess('Subscription plan deleted successfully!'));
      add(FetchRestaurantPlansDataEvent());
    } catch (e) {
      emit(RestaurantPlansError(e.toString()));
    }
  }
}
