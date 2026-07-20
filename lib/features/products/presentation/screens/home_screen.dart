import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/variant_model.dart';
import 'package:smart_shopping_chatbot/shared/providers/product_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch both variants and images in parallel on first load
    Future.microtask(() {
      ref.read(variantListProvider.notifier).fetchVariants();
      ref.read(imageMapProvider.notifier).fetchAllImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variantState = ref.watch(variantListProvider);
    final imageMap = ref.watch(imageMapProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.wait([
              ref.read(variantListProvider.notifier).refresh(),
              ref.read(imageMapProvider.notifier).refresh(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(child: _buildHeader(context, isDark)),

              // ── Search Bar ──
              SliverToBoxAdapter(child: _buildSearchBar(context, isDark)),

              // ── Quick Actions ──
              SliverToBoxAdapter(child: _buildQuickActions(context, isDark)),

              // ── Categories ──
              SliverToBoxAdapter(
                child: _buildSectionTitle(context, 'Danh mục'),
              ),
              SliverToBoxAdapter(child: _buildCategories(context, isDark)),

              // ── Products Showcase (from Variants API) ──
              SliverToBoxAdapter(
                child: _buildSectionTitle(context, 'Sản phẩm nổi bật'),
              ),

              // Loading / Error / Data
              if (variantState.isLoading && variantState.variants.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (variantState.errorMessage != null &&
                  variantState.variants.isEmpty)
                SliverToBoxAdapter(
                  child: _buildErrorState(isDark, variantState.errorMessage!),
                )
              else if (variantState.variants.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState(isDark))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildVariantCard(
                        context,
                        isDark,
                        variantState.variants[index],
                        imageMap,
                      ),
                      childCount: variantState.variants.length,
                    ),
                  ),
                ),

              // Loading more indicator
              if (variantState.isLoading && variantState.variants.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),

      // ── Floating Chat Button ──
      floatingActionButton: _buildChatFAB(context),
    );
  }

  // ─────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello! 👋',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Smart Shopping',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkOnBackground
                        : AppColors.lightOnBackground,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainer
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Search Bar
  // ─────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: GestureDetector(
        onTap: () => context.goNamed('search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainer
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Tìm kiếm sản phẩm...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Quick Actions
  // ─────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      _QuickAction('AI Chat', Icons.auto_awesome_rounded, AppColors.primary),
      _QuickAction(
        'So sánh',
        Icons.compare_arrows_rounded,
        AppColors.secondary,
      ),
      _QuickAction('Khuyến mãi', Icons.local_offer_rounded, AppColors.warning),
      _QuickAction('Mới', Icons.fiber_new_rounded, AppColors.info),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () {
              if (action.label == 'AI Chat') context.goNamed('chatList');
              if (action.label == 'So sánh') context.pushNamed('compare');
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.color.withValues(alpha: 0.15),
                        action.color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(action.icon, color: action.color, size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  action.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Section Title
  // ─────────────────────────────────────────
  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkOnBackground
                  : AppColors.lightOnBackground,
            ),
          ),
          Text(
            'Xem tất cả',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Categories
  // ─────────────────────────────────────────
  Widget _buildCategories(BuildContext context, bool isDark) {
    final categories = [
      _CategoryItem('Áo thun', Icons.checkroom_rounded),
      _CategoryItem('Hoodie', Icons.dry_cleaning_rounded),
      _CategoryItem('Giày', Icons.ice_skating_rounded),
      _CategoryItem('Túi xách', Icons.shopping_bag_rounded),
      _CategoryItem('Phụ kiện', Icons.watch_rounded),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            width: 80,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 6),
                Text(
                  cat.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // Variant Card — real data with image, price, attributes
  // ─────────────────────────────────────────
  Widget _buildVariantCard(
    BuildContext context,
    bool isDark,
    VariantModel variant,
    ImageMapState imageMap,
  ) {
    final color = variant.getAttributeValue('color');
    final size = variant.getAttributeValue('size');

    // Resolve image: variant embedded → Images API by variant → Images API by product → null
    String? imageUrl = variant.primaryImageUrl;
    imageUrl ??= imageMap.getVariantThumbnail(variant.id);
    imageUrl ??= imageMap.getProductThumbnail(variant.productId);

    // Collect all images (for potential gallery view later)
    final allImages = <String>{
      ...variant.imageUrls,
      ...imageMap.getVariantImages(variant.id),
      ...imageMap.getProductImages(variant.productId),
    }.toList();

    return GestureDetector(
      onTap: () => context.pushNamed('productDetail', pathParameters: {'id': variant.productId.toString()}),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product image from merged sources or fallback
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: isDark
                              ? AppColors.darkSurfaceContainer
                              : AppColors.lightSurfaceVariant,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => _buildImageFallback(isDark),
                      )
                    else
                      _buildImageFallback(isDark),

                    // Image count badge (if multiple images)
                    if (allImages.length > 1)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_library_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${allImages.length}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Stock badge
                    if (!variant.inStock)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: Center(
                            child: Text(
                              'Hết hàng',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Attribute chips (Color, Size)
                    if (color != null || size != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Row(
                          children: [
                            if (color != null)
                              _buildChip(color, AppColors.primary),
                            if (color != null && size != null)
                              const SizedBox(width: 4),
                            if (size != null)
                              _buildChip(size, AppColors.secondary),
                          ],
                        ),
                      ),

                    // Wishlist button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkSurface : Colors.white)
                              .withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Details area ──
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name (parent)
                    Text(
                      variant.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Variant name
                    Text(
                      variant.variantName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
                      ),
                    ),
                    const Spacer(),

                    // Stock info
                    Row(
                      children: [
                        Icon(
                          variant.inStock
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 12,
                          color: variant.inStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          variant.inStock
                              ? 'Còn ${variant.stockQuantity}'
                              : 'Hết hàng',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.lightOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Text(
                      variant.formattedPrice,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
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

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImageFallback(bool isDark) {
    return Container(
      color: isDark
          ? AppColors.darkSurfaceContainer
          : AppColors.lightSurfaceVariant,
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 48,
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Error & Empty States
  // ─────────────────────────────────────────
  Widget _buildErrorState(bool isDark, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.lightOnSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(variantListProvider.notifier).fetchVariants(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text('Thử lại', style: GoogleFonts.inter()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.lightOnSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có sản phẩm nào',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Chat FAB
  // ─────────────────────────────────────────
  Widget _buildChatFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.goNamed('chatList'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: Text(
          'AI Chat',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Simple data classes
// ─────────────────────────────────────────
class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickAction(this.label, this.icon, this.color);
}

class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem(this.label, this.icon);
}
