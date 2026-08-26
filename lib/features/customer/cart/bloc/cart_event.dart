abstract class CartEvent {}

class FetchCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final int restaurantId;
  final int? menuItemId;
  final int? addonId;
  final int quantity;
  AddToCartEvent({required this.restaurantId, this.menuItemId, this.addonId, this.quantity = 1});
}

class UpdateCartItemQtyEvent extends CartEvent {
  final int cartItemId;
  final int quantity;
  UpdateCartItemQtyEvent({required this.cartItemId, required this.quantity});
}

class RemoveCartItemEvent extends CartEvent {
  final int cartItemId;
  RemoveCartItemEvent(this.cartItemId);
}

class ClearCartEvent extends CartEvent {}
