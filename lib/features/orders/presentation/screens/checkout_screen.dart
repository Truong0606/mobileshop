import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/core/utils/price_formatter.dart';
import 'package:smart_shopping_chatbot/shared/widgets/app_notification.dart';
import 'package:smart_shopping_chatbot/shared/providers/cart_provider.dart';
import 'package:smart_shopping_chatbot/shared/providers/product_provider.dart';
import 'package:smart_shopping_chatbot/shared/providers/payment_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'VNPAY';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Đóng bàn phím
    FocusScope.of(context).unfocus();

    final url = await ref.read(paymentProvider.notifier).checkout(
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      // PayOS redirect settings
      returnUrl: 'https://shopfake-rag-demo.vercel.app/payment-result', 
      cancelUrl: 'https://shopfake-rag-demo.vercel.app/payment-result',
    );

    if (url != null) {
      // Mở in-app browser
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
        // Sau khi browser đóng, tự động refresh giỏ hàng và đơn hàng
        ref.read(cartProvider.notifier).fetchCart();
        if (mounted) {
          context.goNamed('orders');
        }
      } else {
        if (mounted) {
          AppNotification.show(
            context,
            message: 'Không thể mở trang thanh toán',
            type: NotificationType.error,
          );
        }
      }
    } else {
      final error = ref.read(paymentProvider).error;
      if (mounted && error != null) {
        AppNotification.show(
          context,
          message: error,
          type: NotificationType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartState = ref.watch(cartProvider);
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Thanh toán',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAddressSection(isDark),
            const SizedBox(height: 24),
            _buildPaymentSection(isDark),
            const SizedBox(height: 24),
            _buildOrderSummarySection(isDark, cartState),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark, cartState, paymentState),
    );
  }

  Widget _buildAddressSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Địa chỉ giao hàng',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ nhận hàng',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phương thức thanh toán',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Thanh toán khi nhận hàng (COD)'),
                value: 'COD',
                // ignore: deprecated_member_use
                groupValue: _selectedPaymentMethod,
                // ignore: deprecated_member_use
                onChanged: (val) {
                  // Chỉ giả lập chọn, api hiện tại bắt buộc payos
                  if(val != null) setState(() => _selectedPaymentMethod = val);
                },
              ),
              RadioListTile<String>(
                title: const Text('Thanh toán qua PayOS (QR Code)'),
                value: 'VNPAY', // Đặt giả là VNPAY do PayOS hỗ trợ QR
                // ignore: deprecated_member_use
                groupValue: _selectedPaymentMethod,
                // ignore: deprecated_member_use
                onChanged: (val) {
                  if(val != null) setState(() => _selectedPaymentMethod = val);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection(bool isDark, CartProvider cartState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đơn hàng',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
          ),
        ),
        const SizedBox(height: 12),
        ...cartState.items.map((item) {
          final imageMap = ref.watch(imageMapProvider);
          final imageUrl = imageMap.getVariantThumbnail(item.productVariantId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCartItem(isDark, item.productName, item.variantName, PriceFormatter.formatVNDDouble(item.price), item.quantity, imageUrl),
          );
        }),
      ],
    );
  }

  Widget _buildCartItem(bool isDark, String name, String variantName, String price, int quantity, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.grey),
                  ),
                )
              : const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  variantName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('x$quantity', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, CartProvider cartState, PaymentState paymentState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng thanh toán',
                  style: GoogleFonts.inter(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                Text(
                  PriceFormatter.formatVNDDouble(cartState.totalPrice),
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: paymentState.isLoading || cartState.items.isEmpty ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: paymentState.isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                  'Đặt Hàng',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
