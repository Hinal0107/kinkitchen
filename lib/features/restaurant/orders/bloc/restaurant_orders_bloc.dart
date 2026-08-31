import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinkitchen/shared/repositories/order_repository.dart';
import 'restaurant_orders_event.dart';
import 'restaurant_orders_state.dart';

class RestaurantOrdersBloc extends Bloc<RestaurantOrdersEvent, RestaurantOrdersState> {
  final OrderRepository _orderRepository;

  RestaurantOrdersBloc({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? OrderRepository(),
        super(RestaurantOrdersInitial()) {
    on<FetchRestaurantOrdersDataEvent>(_onFetchOrdersData);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  Future<void> _onFetchOrdersData(FetchRestaurantOrdersDataEvent event, Emitter<RestaurantOrdersState> emit) async {
    emit(RestaurantOrdersLoading());
    try {
      final orders = await _orderRepository.getRestaurantOrders(status: event.status);
      emit(RestaurantOrdersLoaded(orders));
    } catch (e) {
      emit(RestaurantOrdersError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(UpdateOrderStatusEvent event, Emitter<RestaurantOrdersState> emit) async {
    try {
      switch (event.status.toLowerCase()) {
        case 'confirm':
          await _orderRepository.confirmOrder(event.orderId);
          break;
        case 'preparing':
          await _orderRepository.markPreparing(event.orderId);
          break;
        case 'ready':
          await _orderRepository.markReady(event.orderId);
          break;
        case 'out-for-delivery':
        case 'out_for_delivery':
          await _orderRepository.markOutForDelivery(event.orderId);
          break;
        case 'delivered':
          await _orderRepository.markDelivered(event.orderId, event.deliveryOtp ?? '');
          break;
        case 'cancel':
        case 'cancelled':
          await _orderRepository.cancelRestaurantOrder(event.orderId, event.cancelReason ?? '');
          break;
        default:
          await _orderRepository.confirmOrder(event.orderId);
      }
      emit(RestaurantOrdersOperationSuccess('Order status updated to ${event.status}!'));
      add(FetchRestaurantOrdersDataEvent());
    } catch (e) {
      emit(RestaurantOrdersError(e.toString()));
    }
  }
}
