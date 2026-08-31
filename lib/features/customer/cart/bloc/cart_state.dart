import 'package:kinkitchen/shared/models/cart_item.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;

  CartLoaded({
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
  });
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}
