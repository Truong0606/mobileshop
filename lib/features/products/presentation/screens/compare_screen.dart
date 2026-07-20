import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Compare Products',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Product Headers ──
            Row(
              children: [
                const SizedBox(width: 100),
                _productHeader(
                  'iPhone 15 Pro',
                  'Apple',
                  Icons.phone_iphone_rounded,
                  isDark,
                ),
                const SizedBox(width: 12),
                _productHeader(
                  'Galaxy S24 Ultra',
                  'Samsung',
                  Icons.phone_android_rounded,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Comparison rows ──
            _compareRow('Price', '28.990.000₫', '25.990.000₫', isDark),
            _compareRow('Display', '6.7" OLED', '6.8" AMOLED', isDark),
            _compareRow('Chip', 'A17 Pro', 'Snapdragon 8 Gen 3', isDark),
            _compareRow('RAM', '8GB', '12GB', isDark),
            _compareRow('Camera', '48MP', '200MP', isDark),
            _compareRow('Battery', '4441 mAh', '5000 mAh', isDark),
            _compareRow('Weight', '221g', '232g', isDark),
            _compareRow('OS', 'iOS 17', 'Android 14', isDark),
            _compareRow('Rating', '⭐ 4.8', '⭐ 4.7', isDark),
            _compareRow('Storage', '256GB', '256GB', isDark),

            const SizedBox(height: 24),

            // ── Ask AI button ──
            GestureDetector(
              onTap: () => context.pushNamed('chat', pathParameters: {'id': 'compare'}),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ask AI to recommend',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productHeader(String name, String brand, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 36),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface,
              ),
            ),
            Text(
              brand,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compareRow(String label, String val1, String val2, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              val1,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              val2,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
