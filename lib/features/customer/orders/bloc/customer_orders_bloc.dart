import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinkitchen/shared/repositories/order_repository.dart';
import 'customer_orders_event.dart';
import 'customer_orders_state.dart';

class CustomerOrdersBloc extends Bloc<CustomerOrdersEvent, CustomerOrdersState> {
  final OrderRepository _orderRepository;

  CustomerOrdersBloc({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? OrderRepository(),
        super(CustomerOrdersInitial()) {
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<FetchMyOrdersEvent>(_onFetchMyOrders);
    on<FetchOrderDetailsEvent>(_onFetchOrderDetails);
    on<CancelOrderEvent>(_onCancelOrder);
    on<TrackOrderEvent>(_onTrackOrder);
  }

  Future<void> _onPlaceOrder(PlaceOrderEvent event, Emitter<CustomerOrdersState> emit) async {
    emit(CustomerOrdersLoading());
    try {
      final order = await _orderRepository.placeOrder(
        restaurantId: event.restaurantId,
        addressId: event.addressId,
        deliveryNotes: event.deliveryNotes,
        items: event.items,
      );
      emit(OrderPlacedSuccess(order));
    } catch (e) {
      emit(CustomerOrdersError(e.toString()));
    }
  }

  Future<void> _onFetchMyOrders(FetchMyOrdersEvent event, Emitter<CustomerOrdersState> emit) async {
    emit(CustomerOrdersLoading());
    try {
      final orders = await _orderRepository.getMyOrders(status: event.status);
      emit(CustomerOrdersLoaded(orders));
    } catch (e) {
      emit(CustomerOrdersError(e.toString()));
    }
  }

  Future<void> _onFetchOrderDetails(FetchOrderDetailsEvent event, Emitter<CustomerOrdersState> emit) async {
    emit(CustomerOrdersLoading());
    try {
      final order = await _orderRepository.getOrderDetails(event.orderId);
      emit(OrderDetailsLoaded(order));
    } catch (e) {
      emit(CustomerOrdersError(e.toString()));
    }
  }

  Future<void> _onCancelOrder(CancelOrderEvent event, Emitter<CustomerOrdersState> emit) async {
    emit(CustomerOrdersLoading());
    try {
      await _orderRepository.cancelOrder(event.orderId, event.reason);
      add(FetchMyOrdersEvent());
    } catch (e) {
      emit(CustomerOrdersError(e.toString()));
    }
  }

  Future<void> _onTrackOrder(TrackOrderEvent event, Emitter<CustomerOrdersState> emit) async {
    emit(CustomerOrdersLoading());
    try {
      final tracking = await _orderRepository.getOrderTracking(event.orderId);
      emit(OrderTrackingLoaded(tracking));
    } catch (e) {
      emit(CustomerOrdersError(e.toString()));
    }
  }
}
