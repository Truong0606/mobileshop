import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/core/utils/price_formatter.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/variant_model.dart';
import 'package:smart_shopping_chatbot/shared/providers/product_provider.dart';
import 'package:smart_shopping_chatbot/shared/providers/cart_provider.dart';
import 'package:smart_shopping_chatbot/shared/widgets/app_notification.dart';
import 'package:smart_shopping_chatbot/shared/providers/wishlist_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  VariantModel? _selectedVariant;

  @override
  Widget build(BuildContext context) {
    final productIdInt = int.tryParse(widget.productId) ?? 0;
    final detailState = ref.watch(productDetailProvider(productIdInt));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (detailState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (detailState.errorMessage != null || detailState.product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(detailState.errorMessage ?? 'Không tìm thấy sản phẩm'),
        ),
      );
    }

    final product = detailState.product!;
    final variants = detailState.variants;

    // Auto-select first variant if none selected
    if (_selectedVariant == null && variants.isNotEmpty) {
      // Defer state update to avoid build-phase modifications
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedVariant = variants.first);
      });
    }

    final displayPrice = _selectedVariant?.price ?? 0.0;
    final displayStock = _selectedVariant?.stockQuantity ?? 0;
    final displaySku = _selectedVariant?.sku ?? '';

    // Fetch images from provider
    final imageMap = ref.watch(imageMapProvider);
    final images = _selectedVariant != null
        ? imageMap.getVariantImages(_selectedVariant!.id)
        : imageMap.getProductImages(product.id);

    final displayImageUrl = images.isNotEmpty
        ? images.first
        : 'https://via.placeholder.com/400?text=No+Image';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Image Header ──
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: _circleButton(
              context,
              Icons.arrow_back_ios_rounded,
              () => context.pop(),
              isDark,
            ),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final isFav = ref.watch(wishlistProvider).any((e) => e.productId == product.id);
                  return _circleButton(
                    context,
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    () {
                      final item = WishlistItem(
                        productId: product.id,
                        name: product.name,
                        price: displayPrice,
                        imageUrl: displayImageUrl,
                      );
                      ref.read(wishlistProvider.notifier).toggleFavorite(item);
                    },
                    isDark,
                    color: isFav ? AppColors.error : (isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground),
                  );
                }
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark
                    ? AppColors.darkSurfaceContainer
                    : AppColors.lightSurfaceVariant,
                child: CachedNetworkImage(
                  imageUrl: displayImageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Brand & Category ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.brand.isNotEmpty ? product.brand : 'No Brand',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        product.categoryName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkOnSurfaceVariant
                              : AppColors.lightOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Name ──
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkOnBackground
                          : AppColors.lightOnBackground,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Price ──
                  Text(
                    PriceFormatter.formatVNDDouble(displayPrice),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Stock & SKU ──
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: displayStock > 0
                              ? AppColors.success
                              : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        displayStock > 0
                            ? 'Còn $displayStock sản phẩm'
                            : 'Hết hàng',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: displayStock > 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'SKU: $displaySku',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Variants Selection ──
                  if (variants.isNotEmpty) ...[
                    _sectionLabel('Chọn biến thể', isDark),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: variants.map((variant) {
                        final isSelected = _selectedVariant?.id == variant.id;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedVariant = variant),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              variant.variantName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Description ──
                  _sectionLabel('Mô tả sản phẩm', isDark),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Chưa có mô tả',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.lightOnSurface,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Feedbacks ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel(
                        'Đánh giá (${detailState.feedbacks.length})',
                        isDark,
                      ),
                      TextButton(
                        onPressed: onFeedbackTap,
                        child: const Text('Viết đánh giá'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (detailState.feedbacks.isEmpty)
                    Text(
                      'Chưa có đánh giá nào.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...detailState.feedbacks
                        .take(3)
                        .map(
                          (fb) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      fb.accountName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < fb.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(fb.comment),
                                Divider(),
                              ],
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),

                  // ── Ask AI ──
                  GestureDetector(
                    onTap: () =>
                        context.pushNamed('chat', pathParameters: {'id': 'product-${widget.productId}'}),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.secondary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hỏi AI về sản phẩm này',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkOnSurface
                                        : AppColors.lightOnSurface,
                                  ),
                                ),
                                Text(
                                  'So sánh, đặt câu hỏi, nhận tư vấn',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkOnSurfaceVariant
                                        : AppColors.lightOnSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
        ),
        child: Row(
          children: [
            // Cart icon
            GestureDetector(
              onTap: () => context.pushNamed('cart'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Buy now
            Expanded(
              child: GestureDetector(
                onTap: _selectedVariant == null ? null : _addToCart,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _selectedVariant == null
                        ? LinearGradient(colors: [Colors.grey, Colors.grey])
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _selectedVariant == null
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Text(
                    'Thêm vào giỏ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onFeedbackTap() {
    final accountId = "dummy_account_id"; // In real app, get from auth provider
    int rating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đánh giá sản phẩm',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() => rating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Nhập đánh giá của bạn...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final notifier = ref.read(
                            productDetailProvider(
                              int.parse(widget.productId),
                            ).notifier,
                          );
                          await notifier.submitFeedback(
                            accountId: accountId,
                            rating: rating,
                            comment: commentController.text,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          AppNotification.show(
                            context,
                            message: 'Đã gửi đánh giá',
                            type: NotificationType.success,
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          AppNotification.show(
                            context,
                            message: 'Lỗi gửi đánh giá: $e',
                            type: NotificationType.error,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Gửi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addToCart() async {
    if (_selectedVariant != null) {
      try {
        await ref
            .read(cartProvider.notifier)
            .addToCart(_selectedVariant!.id, 1);
        if (mounted) {
          AppNotification.show(
            context,
            message: 'Đã thêm ${_selectedVariant!.variantName} vào giỏ',
            type: NotificationType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          AppNotification.show(
            context,
            message: 'Lỗi thêm vào giỏ: $e',
            type: NotificationType.error,
          );
        }
      }
    }
  }

  Widget _circleButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkSurface : Colors.white).withValues(
              alpha: 0.85,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: color ?? (isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark
            ? AppColors.darkOnBackground
            : AppColors.lightOnBackground,
      ),
    );
  }
}
