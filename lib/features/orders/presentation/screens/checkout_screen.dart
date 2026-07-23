import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/shared/widgets/app_notification.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'COD';

  void _placeOrder() async {
    AppNotification.show(
      context,
      message: 'Đặt hàng thành công',
      type: NotificationType.success,
    );
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.goNamed('orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddressSection(isDark),
          const SizedBox(height: 24),
          _buildPaymentSection(isDark),
          const SizedBox(height: 24),
          _buildOrderSummarySection(isDark),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
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
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nguyễn Văn A',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '0123456789',
                      style: GoogleFonts.inter(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '123 Đường ABC, Phường XYZ, Quận 1, TP HCM',
                      style: GoogleFonts.inter(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Thay đổi'),
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
                onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
              ),
              RadioListTile<String>(
                title: const Text('Thanh toán qua VNPay'),
                value: 'VNPAY',
                // ignore: deprecated_member_use
                groupValue: _selectedPaymentMethod,
                // ignore: deprecated_member_use
                onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection(bool isDark) {
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
        _buildMockCartItem(isDark, 'Áo thun nam', '150.000 đ'),
        const SizedBox(height: 12),
        _buildMockCartItem(isDark, 'Quần jean nữ', '250.000 đ'),
      ],
    );
  }

  Widget _buildMockCartItem(bool isDark, String name, String price) {
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
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            child: const Icon(Icons.image, color: Colors.grey),
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
                ),
                Text(
                  price,
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
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
                  '400.000 đ',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
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
