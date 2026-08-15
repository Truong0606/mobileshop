import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/shared/widgets/app_notification.dart';
import 'package:smart_shopping_chatbot/shared/providers/cart_provider.dart';
import 'package:smart_shopping_chatbot/shared/providers/order_provider.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
  });

  @override
  ConsumerState<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();

            // Intercept PayOS return / cancel redirect URLs
            if (url.contains('payment-result') ||
                url.contains('payment-success') ||
                url.contains('payment-cancel')) {
              _handlePaymentReturn(request.url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentReturn(String url) {
    if (_isFinished) return;
    _isFinished = true;

    // Refresh cart & orders
    ref.read(cartProvider.notifier).fetchCart();
    ref.read(orderProvider.notifier).refresh();

    final isCancel = url.toLowerCase().contains('cancel=true') ||
        url.toLowerCase().contains('status=cancelled') ||
        url.toLowerCase().contains('payment-cancel');

    if (mounted) {
      if (isCancel) {
        AppNotification.show(
          context,
          message: 'Đơn hàng chưa hoàn tất thanh toán',
          type: NotificationType.warning,
        );
      } else {
        AppNotification.show(
          context,
          message: 'Thanh toán đơn hàng thành công!',
          type: NotificationType.success,
        );
      }
      context.goNamed('orders');
    }
  }

  Future<bool> _onWillPop() async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hủy thanh toán?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc chắn muốn rời khỏi trang thanh toán không?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tiếp tục'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rời khỏi'),
          ),
        ],
      ),
    );

    if (shouldClose == true) {
      ref.read(cartProvider.notifier).fetchCart();
      ref.read(orderProvider.notifier).refresh();
      if (mounted) {
        context.goNamed('orders');
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 24),
            onPressed: _onWillPop,
          ),
          title: Text(
            'Thanh toán PayOS',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          bottom: _loadingProgress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _loadingProgress / 100.0,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : null,
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
