import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/core/utils/price_formatter.dart';
import 'package:smart_shopping_chatbot/shared/providers/product_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(
    0,
    5000000,
  ); // Set max to 5 million for clothing
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Load products and images when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).fetchProducts(pageSize: 50);
      ref.read(imageMapProvider.notifier).fetchAllImages();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productState = ref.watch(productListProvider);
    final imageMap = ref.watch(imageMapProvider);

    // Extract unique categories from products
    final categories = ['All'];
    for (final p in productState.products) {
      if (!categories.contains(p.categoryName)) {
        categories.add(p.categoryName);
      }
    }

    // Filter products
    final searchQuery = _searchController.text.toLowerCase();
    final filteredProducts = productState.products.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(searchQuery) ||
          p.brand.toLowerCase().contains(searchQuery);
      final matchesCategory =
          _selectedCategory == 'All' || p.categoryName == _selectedCategory;
      // We don't have direct price on ProductModel (it's on Variant), so price filtering is rough
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Search header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Tìm kiếm',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkOnBackground
                      : AppColors.lightOnBackground,
                ),
              ),
            ),

            // ── Search input ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Tên sản phẩm, thương hiệu...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _showFilters
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.darkSurfaceContainer
                                  : AppColors.lightSurfaceVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: _showFilters ? Colors.white : AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filters ──
            if (_showFilters) _buildFilters(isDark),

            // ── Category chips ──
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final selected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : null,
                    ),
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceContainer
                        : AppColors.lightSurfaceVariant,
                    selectedColor: AppColors.primary,
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Results ──
            Expanded(
              child: productState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productState.errorMessage != null
                  ? Center(child: Text(productState.errorMessage!))
                  : filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'Không tìm thấy sản phẩm nào.',
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final p = filteredProducts[index];
                        final thumbnail = imageMap.getProductThumbnail(p.id);
                        return _buildProductTile(context, p, thumbnail, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Khoảng giá',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 5000000,
            divisions: 50,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              PriceFormatter.formatVNDDouble(_priceRange.start),
              PriceFormatter.formatVNDDouble(_priceRange.end),
            ),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                PriceFormatter.formatVNDDouble(_priceRange.start),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
              Text(
                PriceFormatter.formatVNDDouble(_priceRange.end),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(
    BuildContext context,
    dynamic p,
    String? thumbnail,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => context.pushNamed('productDetail', pathParameters: {'id': p.id.toString()}),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.lightSurfaceVariant,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: thumbnail != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.brand.isNotEmpty ? p.brand : p.categoryName,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
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

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 44,
        color: AppColors.primary.withValues(alpha: 0.6),
      ),
    );
  }
}
