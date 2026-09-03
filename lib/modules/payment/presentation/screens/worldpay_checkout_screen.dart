import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/api_config.dart';
import '../../bloc/payment_bloc.dart';
import '../../bloc/payment_event.dart';
import '../../bloc/payment_state.dart';

class WorldpayCheckoutScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String? orderId;
  final String? customerEmail;
  final String? successUrlPrefix;
  final String? failureUrlPrefix;

  const WorldpayCheckoutScreen({
    super.key,
    required this.amount,
    this.currency = 'USD',
    this.orderId,
    this.customerEmail,
    this.successUrlPrefix,
    this.failureUrlPrefix,
  });

  String get effectiveSuccessUrlPrefix =>
      successUrlPrefix ?? ApiConfig.paymentSuccessUrl;

  String get effectiveFailureUrlPrefix =>
      failureUrlPrefix ?? ApiConfig.paymentFailureUrl;

  @override
  State<WorldpayCheckoutScreen> createState() => _WorldpayCheckoutScreenState();
}

class _WorldpayCheckoutScreenState extends State<WorldpayCheckoutScreen> {
  late final WebViewController _webViewController;
  bool _isWebViewInitialized = false;
  bool _isPageLoading = true;
  int _loadingProgress = 0;
  String? _currentLoadedUrl;

  @override
  void initState() {
    super.initState();
    _initWebViewController();

    // Trigger payment session initialization
    context.read<PaymentBloc>().add(
          InitiatePaymentEvent(
            amount: widget.amount,
            currency: widget.currency,
            orderId: widget.orderId,
            customerEmail: widget.customerEmail,
          ),
        );
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _isPageLoading = true;
              _loadingProgress = 0;
              _currentLoadedUrl = url;
            });
            _handleUrlNavigation(url);
          },
          onProgress: (int progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isPageLoading = false;
              _loadingProgress = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Log or handle web resource errors silently unless main page fails
            debugPrint('Worldpay WebView Resource Error: ${error.description} (Code: ${error.errorCode})');
          },
          onNavigationRequest: (NavigationRequest request) {
            return _handleUrlNavigation(request.url);
          },
        ),
      );

    _isWebViewInitialized = true;
  }

  NavigationDecision _handleUrlNavigation(String url) {
    debugPrint('Worldpay WebView Navigating to: $url');

    // Intercept payment success redirect
    if (url.startsWith(widget.effectiveSuccessUrlPrefix) ||
        url.contains('/payment-success')) {
      final uri = Uri.tryParse(url);
      final transactionId = uri?.queryParameters['transactionId'] ??
          uri?.queryParameters['transId'] ??
          uri?.queryParameters['ref'];

      context.read<PaymentBloc>().add(
            PaymentCompletedEvent(
              isSuccess: true,
              transactionId: transactionId,
              message: 'Payment completed successfully via Worldpay.',
            ),
          );
      return NavigationDecision.prevent;
    }

    // Intercept payment failure / cancellation redirect
    if (url.startsWith(widget.effectiveFailureUrlPrefix) ||
        url.contains('/payment-failed')) {
      final uri = Uri.tryParse(url);
      final errorMessage = uri?.queryParameters['error'] ??
          uri?.queryParameters['message'] ??
          'Payment was failed or cancelled by user.';

      context.read<PaymentBloc>().add(
            PaymentCompletedEvent(
              isSuccess: false,
              message: errorMessage,
            ),
          );
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<bool> _onWillPop() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to exit? Your payment transaction will not be completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Payment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel & Exit'),
          ),
        ],
      ),
    );

    return shouldCancel ?? false;
  }

  void _retryPayment() {
    context.read<PaymentBloc>().add(
          InitiatePaymentEvent(
            amount: widget.amount,
            currency: widget.currency,
            orderId: widget.orderId,
            customerEmail: widget.customerEmail,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Worldpay Secure Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Amount: ${widget.currency} ${widget.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload Checkout Page',
              onPressed: () {
                if (_currentLoadedUrl != null) {
                  _webViewController.reload();
                } else {
                  _retryPayment();
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentUrlReady) {
              if (_isWebViewInitialized) {
                _webViewController.loadRequest(Uri.parse(state.checkoutUrl));
              }
            } else if (state is PaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.green[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );

              // Return true indicating payment succeeded
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            } else if (state is PaymentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PaymentLoading || state is PaymentInitial) {
              final loadingMessage = state is PaymentLoading
                  ? (state.message ?? 'Loading payment page...')
                  : 'Preparing payment...';
              return _buildLoadingState(loadingMessage);
            }

            if (state is PaymentFailure && _currentLoadedUrl == null) {
              return _buildFailureState(state.message);
            }

            return Stack(
              children: [
                if (_isWebViewInitialized)
                  WebViewWidget(controller: _webViewController),
                if (_isPageLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: _loadingProgress > 0 ? _loadingProgress / 100 : null,
                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please do not close or navigate away.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFailureState(String errorMessage) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payment_outlined,
                  size: 48,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Session Failed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _retryPayment,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
