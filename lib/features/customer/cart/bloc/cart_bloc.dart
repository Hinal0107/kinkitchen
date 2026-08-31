import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinkitchen/shared/repositories/cart_repository.dart';
import 'package:kinkitchen/shared/models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepository(),
        super(CartInitial()) {
    on<FetchCartEvent>(_onFetchCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemQtyEvent>(_onUpdateQty);
    on<RemoveCartItemEvent>(_onRemoveItem);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onFetchCart(FetchCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await _cartRepository.getCart();
      emit(_calculateCartState(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.addItem(
        restaurantId: event.restaurantId,
        menuItemId: event.menuItemId,
        addonId: event.addonId,
        quantity: event.quantity,
      );
      add(FetchCartEvent());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateQty(UpdateCartItemQtyEvent event, Emitter<CartState> emit) async {
    try {
      if (event.quantity <= 0) {
        await _cartRepository.removeItem(event.cartItemId);
      } else {
        await _cartRepository.updateQuantity(event.cartItemId, event.quantity);
      }
      add(FetchCartEvent());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveItem(RemoveCartItemEvent event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.removeItem(event.cartItemId);
      add(FetchCartEvent());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.clearCart();
      emit(CartLoaded(cartItems: [], subtotal: 0, deliveryFee: 0, tax: 0, total: 0));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  CartLoaded _calculateCartState(List<CartItem> items) {
    final subtotal = items.fold(0.0, (sum, c) => sum + c.totalPrice);
    final deliveryFee = items.isEmpty ? 0.0 : 2.0;
    final tax = items.isEmpty ? 0.0 : subtotal * 0.05;
    final total = subtotal + deliveryFee + tax;
    return CartLoaded(
      cartItems: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
      total: total,
    );
  }
}
