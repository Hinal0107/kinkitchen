import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionBloc({SubscriptionRepository? subscriptionRepository})
      : _subscriptionRepository = subscriptionRepository ?? SubscriptionRepository(),
        super(SubscriptionInitial()) {
    on<FetchRestaurantPlansEvent>(_onFetchPlans);
    on<SubscribeToPlanEvent>(_onSubscribe);
    on<FetchMySubscriptionsEvent>(_onFetchMySubscriptions);
    on<PauseSubscriptionEvent>(_onPause);
    on<ResumeSubscriptionEvent>(_onResume);
    on<CancelSubscriptionEvent>(_onCancel);
  }

  Future<void> _onFetchPlans(FetchRestaurantPlansEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final plans = await _subscriptionRepository.getRestaurantPlans(event.restaurantId);
      emit(RestaurantPlansLoaded(plans));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onSubscribe(SubscribeToPlanEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await _subscriptionRepository.subscribe(
        restaurantId: event.restaurantId,
        subscriptionPlanId: event.planId,
        startDate: event.startDate,
        addressId: event.addressId,
        autoRenew: event.autoRenew,
      );
      emit(SubscriptionSuccess(subscription));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onFetchMySubscriptions(FetchMySubscriptionsEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final subscriptions = await _subscriptionRepository.getMySubscriptions();
      emit(MySubscriptionsLoaded(subscriptions));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onPause(PauseSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    try {
      await _subscriptionRepository.pauseSubscription(event.subscriptionId);
      add(FetchMySubscriptionsEvent());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onResume(ResumeSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    try {
      await _subscriptionRepository.resumeSubscription(event.subscriptionId);
      add(FetchMySubscriptionsEvent());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCancel(CancelSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    try {
      await _subscriptionRepository.cancelSubscription(event.subscriptionId);
      add(FetchMySubscriptionsEvent());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
}
