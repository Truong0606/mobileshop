import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 50000000);
  bool _showFilters = false;

  final _categories = [
    'All',
    'Phones',
    'Laptops',
    'Audio',
    'Watches',
    'Cameras',
  ];

  final _products = [
    _SearchProduct(
      'iPhone 15 Pro',
      'Apple',
      28990000,
      Icons.phone_iphone_rounded,
      4.8,
      256,
      true,
    ),
    _SearchProduct(
      'Galaxy S24 Ultra',
      'Samsung',
      25990000,
      Icons.phone_android_rounded,
      4.7,
      189,
      true,
    ),
    _SearchProduct(
      'MacBook Air M3',
      'Apple',
      27490000,
      Icons.laptop_mac_rounded,
      4.9,
      312,
      true,
    ),
    _SearchProduct(
      'AirPods Pro 2',
      'Apple',
      5490000,
      Icons.headphones_rounded,
      4.6,
      543,
      true,
    ),
    _SearchProduct(
      'Sony WH-1000XM5',
      'Sony',
      6990000,
      Icons.headset_rounded,
      4.8,
      421,
      true,
    ),
    _SearchProduct(
      'iPad Air M2',
      'Apple',
      16990000,
      Icons.tablet_mac_rounded,
      4.7,
      178,
      true,
    ),
    _SearchProduct(
      'Galaxy Watch 6',
      'Samsung',
      6490000,
      Icons.watch_rounded,
      4.4,
      134,
      false,
    ),
    _SearchProduct(
      'Sony A7 IV',
      'Sony',
      42990000,
      Icons.camera_alt_rounded,
      4.9,
      89,
      true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Search header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Search',
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
                        hintText: 'Search products, brands...',
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
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
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
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final p = _products[index];
                  return _buildProductTile(context, p, isDark, index);
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
            'Price Range',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 50000000,
            divisions: 50,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              _formatVND(_priceRange.start),
              _formatVND(_priceRange.end),
            ),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatVND(_priceRange.start),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
              Text(
                _formatVND(_priceRange.end),
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
    _SearchProduct p,
    bool isDark,
    int index,
  ) {
    return GestureDetector(
      onTap: () => context.push('/product/$index'),
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
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        p.icon,
                        size: 44,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    if (!p.inStock)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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
                      p.brand,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFD700),
                          size: 13,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${p.rating} (${p.reviews})',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.lightOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatVND(p.price.toDouble()),
                      style: GoogleFonts.inter(
                        fontSize: 14,
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

  String _formatVND(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    buffer.write('₫');
    return buffer.toString();
  }
}

class _SearchProduct {
  final String name, brand;
  final int price;
  final IconData icon;
  final double rating;
  final int reviews;
  final bool inStock;
  const _SearchProduct(
    this.name,
    this.brand,
    this.price,
    this.icon,
    this.rating,
    this.reviews,
    this.inStock,
  );
}
