import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any payment action is taken.
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// State emitted while fetching the checkout session or preparing the payment.
class PaymentLoading extends PaymentState {
  final String? message;

  const PaymentLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State emitted when Worldpay checkout URL is successfully retrieved from backend.
class PaymentUrlReady extends PaymentState {
  final String checkoutUrl;

  const PaymentUrlReady(this.checkoutUrl);

  @override
  List<Object?> get props => [checkoutUrl];
}

/// State emitted when payment succeeds via Worldpay redirect.
class PaymentSuccess extends PaymentState {
  final String? transactionId;
  final String message;

  const PaymentSuccess({
    this.transactionId,
    this.message = 'Payment completed successfully!',
  });

  @override
  List<Object?> get props => [transactionId, message];
}

/// State emitted when payment fails or encounters an error.
class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}
