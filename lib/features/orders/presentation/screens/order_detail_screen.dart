import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/core/utils/price_formatter.dart';
import 'package:smart_shopping_chatbot/features/orders/data/models/order_model.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/variant_model.dart';
import 'package:smart_shopping_chatbot/shared/providers/order_provider.dart';
import 'package:smart_shopping_chatbot/shared/providers/product_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderIdStr;

  const OrderDetailScreen({super.key, required this.orderIdStr});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late Future<OrderModel> _orderFuture;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    Future.microtask(() {
      ref.read(variantListProvider.notifier).fetchVariants();
      ref.read(imageMapProvider.notifier).fetchAllImages();
    });
  }

  void _loadOrder() {
    final orderId = int.tryParse(widget.orderIdStr) ?? 0;
    _orderFuture = ref.read(orderRepositoryProvider).getOrderById(orderId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('orders');
            }
          },
        ),
        title: Text(
          'Chi tiết đơn hàng',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkOnBackground
                : AppColors.lightOnBackground,
          ),
        ),
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        iconTheme: IconThemeData(
          color:
              isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
        ),
      ),
      body: FutureBuilder<OrderModel>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Không thể tải chi tiết đơn hàng',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadOrder();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng'));
          }

          final normStatus = order.status.toUpperCase();
          Color statusColor;
          String statusText;
          IconData statusIcon;

          if (normStatus == 'PAID') {
            statusColor = AppColors.success;
            statusText = 'Đã thanh toán';
            statusIcon = Icons.check_circle_outline_rounded;
          } else if (normStatus == 'PENDING') {
            statusColor = AppColors.warning;
            statusText = 'Chờ thanh toán';
            statusIcon = Icons.access_time_rounded;
          } else if (normStatus == 'CANCELLED') {
            statusColor = AppColors.error;
            statusText = 'Đã hủy';
            statusIcon = Icons.cancel_outlined;
          } else {
            statusColor = Colors.blue;
            statusText = order.status;
            statusIcon = Icons.local_shipping_outlined;
          }

          String dateStr = order.createdAt ?? '';
          if (dateStr.isNotEmpty) {
            try {
              final dt = DateTime.parse(dateStr).toLocal();
              dateStr = DateFormat('dd/MM/yyyy HH:mm').format(dt);
            } catch (_) {}
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadOrder();
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Status Banner Card ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  statusText,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: statusColor,
                                  ),
                                ),
                                if (order.paymentCode != null &&
                                    order.paymentCode!.isNotEmpty)
                                  Text(
                                    '#${order.paymentCode}',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            if (dateStr.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Thời gian: $dateStr',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Receiver Information ──
                _buildSectionHeader('Thông tin nhận hàng', isDark),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.person_outline_rounded,
                        'Người nhận',
                        order.receiverName.isNotEmpty
                            ? order.receiverName
                            : 'Chưa cập nhật',
                        isDark,
                      ),
                      const Divider(height: 18),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Số điện thoại',
                        order.receiverPhone.isNotEmpty
                            ? order.receiverPhone
                            : 'Chưa cập nhật',
                        isDark,
                      ),
                      const Divider(height: 18),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Địa chỉ giao hàng',
                        order.shippingAddress.isNotEmpty
                            ? order.shippingAddress
                            : 'Chưa cập nhật',
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Payment Information ──
                _buildSectionHeader('Thông tin thanh toán', isDark),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.payment_rounded,
                        'Phương thức thanh toán',
                        order.paymentMethod ?? 'Trực tuyến (PayOS / Chuyển khoản)',
                        isDark,
                      ),
                      if (order.paymentCode != null &&
                          order.paymentCode!.isNotEmpty) ...[
                        const Divider(height: 18),
                        _buildInfoRow(
                          Icons.tag_rounded,
                          'Mã giao dịch',
                          order.paymentCode!,
                          isDark,
                        ),
                      ],
                      const Divider(height: 18),
                      _buildInfoRow(
                        Icons.verified_outlined,
                        'Trạng thái thanh toán',
                        statusText,
                        isDark,
                        valueColor: statusColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Products List ──
                _buildSectionHeader(
                    'Sản phẩm đã mua (${order.items.length})', isDark),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < order.items.length; i++) ...[
                        if (i > 0) const Divider(height: 20),
                        _buildProductItemRow(order.items[i], isDark),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Order Summary ──
                _buildSectionHeader('Tổng kết đơn hàng', isDark),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tạm tính',
                              style: GoogleFonts.inter(
                                  color: Colors.grey, fontSize: 13)),
                          Text(
                            PriceFormatter.formatVNDDouble(order.totalAmount),
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Phí vận chuyển',
                              style: GoogleFonts.inter(
                                  color: Colors.grey, fontSize: 13)),
                          Text(
                            'Miễn phí',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng thanh toán',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            PriceFormatter.formatVNDDouble(order.totalAmount),
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Action Button if Pending ──
                if (normStatus == 'PENDING' &&
                    order.paymentUrl != null &&
                    order.paymentUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: ElevatedButton(
                      onPressed: () {
                        context.pushNamed(
                          'payment_webview',
                          extra: order.paymentUrl,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Tiến hành thanh toán đơn hàng',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ??
                      (isDark
                          ? AppColors.darkOnSurface
                          : AppColors.lightOnSurface),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductItemRow(OrderItemModel item, bool isDark) {
    final displayName = item.productVariantName.isNotEmpty
        ? item.productVariantName
        : item.productName;
    final itemTotal = item.price * item.quantity;

    final variantState = ref.watch(variantListProvider);
    final imageMap = ref.watch(imageMapProvider);

    String? imageUrl = item.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      final name = displayName.toLowerCase().trim();
      VariantModel? matched;
      for (final v in variantState.variants) {
        final vName = v.variantName.toLowerCase().trim();
        final pName = v.productName.toLowerCase().trim();
        if (vName == name ||
            '$pName - $vName' == name ||
            '$pName $vName' == name) {
          matched = v;
          break;
        }
      }
      if (matched == null) {
        for (final v in variantState.variants) {
          final vName = v.variantName.toLowerCase().trim();
          final pName = v.productName.toLowerCase().trim();
          if ((vName.isNotEmpty && name.contains(vName)) ||
              (pName.isNotEmpty && name.contains(pName))) {
            matched = v;
            break;
          }
        }
      }

      if (matched != null) {
        imageUrl = matched.imageUrls.isNotEmpty
            ? matched.imageUrls.first
            : imageMap.getProductThumbnail(matched.productId);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.grey,
                    ),
                  ),
                )
              : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkOnSurface
                      : AppColors.lightOnSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${PriceFormatter.formatVNDDouble(item.price)} × ${item.quantity}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    PriceFormatter.formatVNDDouble(itemTotal),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
