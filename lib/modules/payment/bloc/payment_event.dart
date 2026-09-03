import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user initiates a payment session with Worldpay.
class InitiatePaymentEvent extends PaymentEvent {
  final double amount;
  final String currency;
  final String? orderId;
  final String? customerEmail;
  final Map<String, dynamic>? customPayload;

  const InitiatePaymentEvent({
    required this.amount,
    this.currency = 'USD',
    this.orderId,
    this.customerEmail,
    this.customPayload,
  });

  @override
  List<Object?> get props => [
        amount,
        currency,
        orderId,
        customerEmail,
        customPayload,
      ];
}

/// Triggered when the WebView navigation intercepts a payment completion callback.
class PaymentCompletedEvent extends PaymentEvent {
  final bool isSuccess;
  final String? message;
  final String? transactionId;

  const PaymentCompletedEvent({
    required this.isSuccess,
    this.message,
    this.transactionId,
  });

  @override
  List<Object?> get props => [isSuccess, message, transactionId];
}
