import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Phương thức thanh toán',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppColors.lightOnBackground,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightOnBackground),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPaymentCard(
            title: 'Tiền mặt (COD)',
            subtitle: 'Thanh toán khi nhận hàng',
            icon: Icons.money_rounded,
            isSelected: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentCard(
            title: 'Thẻ tín dụng/Ghi nợ',
            subtitle: 'Visa, MasterCard, JCB',
            icon: Icons.credit_card_rounded,
            isSelected: false,
          ),
          const SizedBox(height: 12),
          _buildPaymentCard(
            title: 'Ví MoMo',
            subtitle: 'Thanh toán qua ví điện tử MoMo',
            icon: Icons.account_balance_wallet_rounded,
            isSelected: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.dividerLight,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 32),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : null,
        onTap: () {},
      ),
    );
  }
}
