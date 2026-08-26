abstract class CustomerOrdersEvent {}

class PlaceOrderEvent extends CustomerOrdersEvent {
  final int restaurantId;
  final int addressId;
  final String? deliveryNotes;
  final List<Map<String, dynamic>> items;
  PlaceOrderEvent({
    required this.restaurantId,
    required this.addressId,
    this.deliveryNotes,
    required this.items,
  });
}

class FetchMyOrdersEvent extends CustomerOrdersEvent {
  final String? status;
  FetchMyOrdersEvent({this.status});
}

class FetchOrderDetailsEvent extends CustomerOrdersEvent {
  final int orderId;
  FetchOrderDetailsEvent(this.orderId);
}

class CancelOrderEvent extends CustomerOrdersEvent {
  final int orderId;
  final String reason;
  CancelOrderEvent({required this.orderId, required this.reason});
}

class TrackOrderEvent extends CustomerOrdersEvent {
  final int orderId;
  TrackOrderEvent(this.orderId);
}
