import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Về ứng dụng',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shopping_bag_rounded, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Smart Shopping',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Phiên bản 0.1.0',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {},
              child: const Text('Điều khoản sử dụng'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Chính sách bảo mật'),
            ),
          ],
        ),
      ),
    );
  }
}
