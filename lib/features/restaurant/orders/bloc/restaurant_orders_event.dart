abstract class RestaurantOrdersEvent {}

class FetchRestaurantOrdersDataEvent extends RestaurantOrdersEvent {
  final String? status;
  FetchRestaurantOrdersDataEvent({this.status});
}

class UpdateOrderStatusEvent extends RestaurantOrdersEvent {
  final int orderId;
  final String status; // confirm, preparing, ready, out-for-delivery, delivered, cancel
  final String? deliveryOtp;
  final String? cancelReason;
  UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
    this.deliveryOtp,
    this.cancelReason,
  });
}
