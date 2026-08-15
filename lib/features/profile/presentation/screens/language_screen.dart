import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/shared/providers/locale_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          currentLocale.languageCode == 'vi' ? 'Ngôn ngữ' : 'Language',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
            fontSize: 18,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildLanguageItem(
            context: context,
            title: 'Tiếng Việt (Việt Nam)',
            isSelected: currentLocale.languageCode == 'vi',
            isDark: isDark,
            onTap: () {
              ref.read(localeProvider.notifier).setVietnamese();
            },
          ),
          _buildLanguageItem(
            context: context,
            title: 'English (US)',
            isSelected: currentLocale.languageCode == 'en',
            isDark: isDark,
            onTap: () {
              ref.read(localeProvider.notifier).setEnglish();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
          : null,
      onTap: onTap,
    );
  }
}
