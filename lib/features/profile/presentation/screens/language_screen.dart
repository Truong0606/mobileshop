import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Ngôn ngữ',
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
            title: const Text('Tiếng Việt (Việt Nam)'),
            trailing: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            onTap: () {},
          ),
          ListTile(
            title: const Text('English (US)'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
