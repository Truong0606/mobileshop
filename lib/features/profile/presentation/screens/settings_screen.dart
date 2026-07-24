import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Cài đặt tài khoản',
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
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Đổi mật khẩu'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security_rounded),
            title: const Text('Bảo mật & Quyền riêng tư'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
            title: const Text('Xóa tài khoản', style: TextStyle(color: AppColors.error)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
