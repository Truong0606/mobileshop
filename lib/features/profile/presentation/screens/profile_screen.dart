import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/shared/providers/auth_provider.dart';
import 'package:smart_shopping_chatbot/shared/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header (Login/Register or User Info) ──
              _buildHeader(context, ref, isDark, authState),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ── Order Status Row ──
                    _buildOrderSection(isDark),

                    const SizedBox(height: 20),

                    // ── Stats Row (only when logged in) ──
                    if (authState.isLoggedIn) ...[
                      Row(
                        children: [
                          _statCard(
                            '12',
                            'Đơn hàng',
                            Icons.shopping_bag_rounded,
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _statCard(
                            '5',
                            'Yêu thích',
                            Icons.favorite_rounded,
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _statCard('28', 'Chat', Icons.chat_rounded, isDark),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Menu Sections ──
                    if (authState.isLoggedIn) ...[
                      _sectionTitle('Tài khoản', isDark),
                      _menuItem(
                        Icons.shopping_bag_outlined,
                        'Đơn mua',
                        isDark,
                        onTap: () {},
                      ),
                      _menuItem(
                        Icons.favorite_border_rounded,
                        'Yêu thích',
                        isDark,
                        onTap: () {},
                      ),
                      _menuItem(
                        Icons.location_on_outlined,
                        'Địa chỉ',
                        isDark,
                        onTap: () {},
                      ),
                      _menuItem(
                        Icons.payment_rounded,
                        'Phương thức thanh toán',
                        isDark,
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                    ],

                    _sectionTitle('Cài đặt', isDark),
                    _menuItem(
                      Icons.dark_mode_outlined,
                      'Chế độ tối',
                      isDark,
                      trailing: _buildThemeSwitch(context, isDark),
                    ),
                    _menuItem(
                      Icons.language_rounded,
                      'Ngôn ngữ',
                      isDark,
                      subtitle: 'Tiếng Việt',
                    ),
                    _menuItem(
                      Icons.notifications_outlined,
                      'Thông báo',
                      isDark,
                      onTap: () {},
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle('Hỗ trợ', isDark),
                    _menuItem(
                      Icons.help_outline_rounded,
                      'Trung tâm trợ giúp',
                      isDark,
                      onTap: () {},
                    ),
                    _menuItem(
                      Icons.info_outline_rounded,
                      'Về ứng dụng',
                      isDark,
                      onTap: () {},
                    ),

                    if (authState.isLoggedIn)
                      _menuItem(
                        Icons.logout_rounded,
                        'Đăng xuất',
                        isDark,
                        color: AppColors.error,
                        onTap: () => ref.read(authProvider.notifier).logout(),
                      ),

                    const SizedBox(height: 32),
                    Text(
                      'Smart Shopping v0.1.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.lightOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Header — Shopee-style with Login/Register or User Info
  // ─────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AuthState authState,
  ) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              // Top row — settings & cart icons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _headerIcon(Icons.settings_outlined, () {}),
                  const SizedBox(width: 12),
                  _headerIcon(Icons.shopping_cart_outlined, () {}),
                  const SizedBox(width: 12),
                  _headerIcon(Icons.chat_outlined, () => context.go('/chat')),
                ],
              ),
              const SizedBox(height: 16),

              // User row
              if (authState.isLoggedIn)
                _buildLoggedInHeader(context, authState)
              else
                _buildGuestHeader(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Guest Header (Not Logged In) ──
  Widget _buildGuestHeader(BuildContext context) {
    return Row(
      children: [
        // Avatar placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white70,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),

        // Login button (outlined)
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/login'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Đăng nhập',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Register button (filled white)
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/register'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Đăng ký',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Logged In Header ──
  Widget _buildLoggedInHeader(BuildContext context, AuthState authState) {
    final user = authState.user!;
    // Mask email: show first char, mask middle, show last char + domain
    final maskedEmail = _maskEmail(user.email);

    return Row(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: user.avatarUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(user.avatarUrl!, fit: BoxFit.cover),
                )
              : Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 16),

        // Name & email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                maskedEmail,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),

        // Edit profile
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Order Status Section (Shopee-style)
  // ─────────────────────────────────────────
  Widget _buildOrderSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn mua',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkOnSurface
                      : AppColors.lightOnSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Xem lịch sử mua hàng',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.lightOnSurfaceVariant,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _orderStatus(Icons.inventory_2_outlined, 'Chờ xác nhận', isDark),
              _orderStatus(
                Icons.local_shipping_outlined,
                'Chờ lấy hàng',
                isDark,
              ),
              _orderStatus(Icons.delivery_dining_outlined, 'Đang giao', isDark),
              _orderStatus(Icons.star_border_rounded, 'Đánh giá', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderStatus(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          size: 26,
          color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Stat Cards
  // ─────────────────────────────────────────
  Widget _statCard(String value, String label, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.lightOnSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    bool isDark, {
    String? subtitle,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    final fgColor =
        color ?? (isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: fgColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.lightOnSurfaceVariant,
            size: 20,
          ),
      onTap: onTap,
    );
  }

  Widget _buildThemeSwitch(BuildContext context, bool isDark) {
    return Consumer(
      builder: (context, ref, _) {
        return Switch.adaptive(
          value: isDark,
          activeTrackColor: AppColors.primary,
          onChanged: (_) {
            ref.read(themeProvider.notifier).toggle();
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return '$local@$domain';
    return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@$domain';
  }
}
