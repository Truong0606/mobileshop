import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/shared/providers/product_provider.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/product_model.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/variant_model.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  ProductModel? _product1;
  ProductModel? _product2;
  List<VariantModel>? _variants1;
  List<VariantModel>? _variants2;

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
          'So sánh sản phẩm',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Product Picker Row ──
            Row(
              children: [
                Expanded(child: _buildProductSlot(1, _product1, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildProductSlot(2, _product2, isDark)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Comparison Table (only when both products selected) ──
            if (_product1 != null && _product2 != null) ...[
              _buildComparisonTable(isDark),
              const SizedBox(height: 24),

              // ── Ask AI button ──
              GestureDetector(
                onTap: _navigateToAICompare,
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
                        'Nhờ AI so sánh',
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
            ] else ...[
              // ── Empty state hint ──
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.compare_arrows_rounded,
                      size: 64,
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.lightOnSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chọn 2 sản phẩm để so sánh',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.lightOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Product Slot (tap to pick)
  // ─────────────────────────────────────────
  Widget _buildProductSlot(int slot, ProductModel? product, bool isDark) {
    final imageMap = ref.watch(imageMapProvider);
    String? imageUrl;
    if (product != null) {
      imageUrl = imageMap.byProductId[product.id]?.firstOrNull;
    }

    return GestureDetector(
      onTap: () => _showProductPicker(slot),
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: product != null
                ? AppColors.primary.withValues(alpha: 0.5)
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: product != null ? 1.5 : 1,
          ),
        ),
        child: product != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    )
                  else
                    Icon(Icons.shopping_bag_outlined,
                        color: AppColors.primary, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
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
                  Text(
                    product.brand,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.primary),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 40,
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chọn sản phẩm $slot',
                    style: GoogleFonts.inter(
                      fontSize: 13,
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

  // ─────────────────────────────────────────
  // Product Picker Bottom Sheet
  // ─────────────────────────────────────────
  void _showProductPicker(int slot) {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final productState = ref.watch(productListProvider);
            final imageMap = ref.watch(imageMapProvider);
            final query = searchController.text.toLowerCase();

            final filtered = productState.products.where((p) {
              if (query.isEmpty) return true;
              return p.name.toLowerCase().contains(query) ||
                  p.brand.toLowerCase().contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Chọn sản phẩm $slot',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
                      ),
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Tìm sản phẩm...',
                        prefixIcon:
                            const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product list
                  Expanded(
                    child: productState.isLoading && productState.products.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'Không tìm thấy sản phẩm',
                                  style: GoogleFonts.inter(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filtered.length,
                                itemBuilder: (ctx, index) {
                                  final product = filtered[index];
                                  final imgUrl = imageMap
                                      .byProductId[product.id]?.firstOrNull;
                                  final isSelected =
                                      (_product1?.id == product.id &&
                                              slot == 1) ||
                                          (_product2?.id == product.id &&
                                              slot == 2);
                                  final isOtherSlot =
                                      (slot == 1 &&
                                              _product2?.id == product.id) ||
                                          (slot == 2 &&
                                              _product1?.id == product.id);

                                  return ListTile(
                                    leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkSurfaceVariant
                                            : AppColors.lightSurfaceVariant,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: imgUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: imgUrl,
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
                                                            Icons.image,
                                                            color:
                                                                Colors.grey),
                                              ),
                                            )
                                          : const Icon(Icons.image,
                                              color: Colors.grey),
                                    ),
                                    title: Text(
                                      product.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        color: isOtherSlot
                                            ? Colors.grey
                                            : (isDark
                                                ? AppColors.darkOnSurface
                                                : AppColors.lightOnSurface),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${product.brand} • ${product.categoryName}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle,
                                            color: AppColors.primary)
                                        : isOtherSlot
                                            ? Text(
                                                'Đã chọn',
                                                style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    color: Colors.grey),
                                              )
                                            : null,
                                    enabled: !isOtherSlot,
                                    onTap: isOtherSlot
                                        ? null
                                        : () {
                                            _selectProduct(slot, product);
                                            Navigator.pop(ctx);
                                          },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // Select product & load its variants
  // ─────────────────────────────────────────
  void _selectProduct(int slot, ProductModel product) {
    final allVariants = ref.read(variantListProvider).variants;
    final productVariants =
        allVariants.where((v) => v.productId == product.id).toList();

    setState(() {
      if (slot == 1) {
        _product1 = product;
        _variants1 = productVariants;
      } else {
        _product2 = product;
        _variants2 = productVariants;
      }
    });
  }

  // ─────────────────────────────────────────
  // Comparison Table
  // ─────────────────────────────────────────
  Widget _buildComparisonTable(bool isDark) {
    final p1 = _product1!;
    final p2 = _product2!;
    final v1 = _variants1 ?? [];
    final v2 = _variants2 ?? [];

    // Compute summary values from variants
    final price1 = v1.isNotEmpty
        ? v1.map((v) => v.price).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final price2 = v2.isNotEmpty
        ? v2.map((v) => v.price).reduce((a, b) => a < b ? a : b)
        : 0.0;

    final stock1 = v1.fold<int>(0, (sum, v) => sum + v.stockQuantity);
    final stock2 = v2.fold<int>(0, (sum, v) => sum + v.stockQuantity);

    final variantCount1 = v1.length.toString();
    final variantCount2 = v2.length.toString();

    String formatPrice(double price) {
      if (price == 0) return 'N/A';
      return '${(price ~/ 1000).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}.000₫';
    }

    // Collect unique attribute names across both products
    final allAttrNames = <String>{};
    for (final v in v1) {
      for (final attr in v.attributes) {
        allAttrNames.add(attr.attributeName);
      }
    }
    for (final v in v2) {
      for (final attr in v.attributes) {
        allAttrNames.add(attr.attributeName);
      }
    }

    String getAttrValues(List<VariantModel> variants, String attrName) {
      final values = <String>{};
      for (final v in variants) {
        for (final attr in v.attributes) {
          if (attr.attributeName == attrName) {
            values.addAll(attr.values.map((item) => item.valueText));
          }
        }
      }
      return values.isEmpty ? '—' : values.join(', ');
    }

    return Column(
      children: [
        _compareRow('Thương hiệu', p1.brand, p2.brand, isDark),
        _compareRow('Danh mục', p1.categoryName, p2.categoryName, isDark),
        _compareRow('Giá từ', formatPrice(price1), formatPrice(price2), isDark),
        _compareRow('Tồn kho', '$stock1', '$stock2', isDark),
        _compareRow('Biến thể', variantCount1, variantCount2, isDark),
        ...allAttrNames.map((name) => _compareRow(
              name,
              getAttrValues(v1, name),
              getAttrValues(v2, name),
              isDark,
            )),
      ],
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
            width: 90,
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

  // ─────────────────────────────────────────
  // Navigate to AI Chat with compare prompt
  // ─────────────────────────────────────────
  void _navigateToAICompare() {
    if (_product1 == null || _product2 == null) return;

    final prompt =
        'So sánh chi tiết 2 sản phẩm sau và đưa ra lời khuyên nên mua sản phẩm nào:\n'
        '1. ${_product1!.name} (${_product1!.brand}) - ${_product1!.categoryName}\n'
        '2. ${_product2!.name} (${_product2!.brand}) - ${_product2!.categoryName}';

    context.pushNamed(
      'chat',
      pathParameters: {'id': 'new'},
      extra: prompt,
    );
  }
}
