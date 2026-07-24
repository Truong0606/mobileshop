import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _promotions = true;
  bool _orders = true;
  bool _updates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Thông báo',
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
        children: [
          SwitchListTile.adaptive(
            title: const Text('Khuyến mãi & Ưu đãi'),
            subtitle: const Text('Nhận thông báo về các chương trình giảm giá'),
            value: _promotions,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _promotions = val),
          ),
          SwitchListTile.adaptive(
            title: const Text('Cập nhật đơn hàng'),
            subtitle: const Text('Trạng thái giao hàng và xác nhận'),
            value: _orders,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _orders = val),
          ),
          SwitchListTile.adaptive(
            title: const Text('Cập nhật hệ thống'),
            subtitle: const Text('Tính năng mới và bảo trì'),
            value: _updates,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _updates = val),
          ),
        ],
      ),
    );
  }
}
