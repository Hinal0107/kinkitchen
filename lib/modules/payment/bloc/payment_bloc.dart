import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final http.Client _httpClient;
  final String? _baseUrl;
  final String? _authToken;

  PaymentBloc({
    http.Client? httpClient,
    String? baseUrl,
    String? authToken,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl,
        _authToken = authToken,
        super(const PaymentInitial()) {
    on<InitiatePaymentEvent>(_onInitiatePayment);
    on<PaymentCompletedEvent>(_onPaymentCompleted);
  }

  Future<void> _onInitiatePayment(
    InitiatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading(message: 'Creating Worldpay checkout session...'));

    try {
      final targetBaseUrl = _baseUrl ?? ApiConfig.baseUrl;
      final String sessionEndpoint = targetBaseUrl.endsWith('/')
          ? '${targetBaseUrl}payments/worldpay/create-session'
          : (targetBaseUrl.contains('/api/')
              ? '$targetBaseUrl/payments/worldpay/create-session'
              : '$targetBaseUrl${ApiConfig.worldpayCreateSession}');

      final endpointUri = Uri.parse(sessionEndpoint);

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null && _authToken.isNotEmpty)
          'Authorization': 'Bearer $_authToken',
      };

      final body = jsonEncode({
        'amount': event.amount,
        'currency': event.currency,
        if (event.orderId != null) 'order_id': event.orderId,
        if (event.customerEmail != null) 'email': event.customerEmail,
        ...?event.customPayload,
      });

      final response = await _httpClient
          .post(endpointUri, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);

        String? checkoutUrl;
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
            final inner = decoded['data'] as Map<String, dynamic>;
            checkoutUrl = inner['checkoutUrl'] ?? inner['checkout_url'] ?? inner['url'];
          } else {
            checkoutUrl = decoded['checkoutUrl'] ?? decoded['checkout_url'] ?? decoded['url'];
          }
        }

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          emit(PaymentUrlReady(checkoutUrl));
        } else {
          emit(const PaymentFailure('Backend response missing checkout URL.'));
        }
      } else {
        String errorMessage = 'Failed to create payment session (${response.statusCode})';
        try {
          final errorObj = jsonDecode(response.body);
          if (errorObj is Map<String, dynamic> && errorObj.containsKey('message')) {
            errorMessage = errorObj['message'];
          }
        } catch (_) {}
        emit(PaymentFailure(errorMessage));
      }
    } on SocketException {
      emit(const PaymentFailure('Network error. Please check your internet connection and try again.'));
    } on http.ClientException catch (e) {
      emit(PaymentFailure('Network connection error: ${e.message}'));
    } catch (e) {
      emit(PaymentFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onPaymentCompleted(
    PaymentCompletedEvent event,
    Emitter<PaymentState> emit,
  ) {
    if (event.isSuccess) {
      emit(PaymentSuccess(
        transactionId: event.transactionId,
        message: event.message ?? 'Payment processed successfully via Worldpay.',
      ));
    } else {
      emit(PaymentFailure(
        event.message ?? 'Payment was cancelled or unsuccessful.',
      ));
    }
  }
}
