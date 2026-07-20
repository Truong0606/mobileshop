/// Price and currency formatting utilities for the shopping chatbot.
///
/// All monetary values are formatted in Vietnamese Dong (VND) with
/// appropriate thousand-separator dots and the ₫ currency symbol.
library;

import 'package:intl/intl.dart';

/// Utility class for formatting prices, discounts, and price ranges.
abstract final class PriceFormatter {
  static final _vndFormat = NumberFormat('#,###', 'vi_VN');

  /// Formats an integer price in Vietnamese Dong.
  ///
  /// Example: `formatVND(1500000)` → `'1.500.000₫'`
  ///
  /// If [showSymbol] is false, the ₫ symbol is omitted.
  static String formatVND(int price, {bool showSymbol = true}) {
    // NumberFormat with vi_VN locale uses '.' as grouping separator
    final formatted = _vndFormat.format(price).replaceAll(',', '.');
    return showSymbol ? '$formatted₫' : formatted;
  }

  /// Formats a double price in Vietnamese Dong, rounding to the nearest integer.
  ///
  /// Example: `formatVNDDouble(1500000.5)` → `'1.500.001₫'`
  static String formatVNDDouble(double price, {bool showSymbol = true}) {
    return formatVND(price.round(), showSymbol: showSymbol);
  }

  /// Formats a discount percentage.
  ///
  /// Example: `formatDiscount(20)` → `'-20%'`
  ///
  /// Returns an empty string if [discountPercent] is `0` or negative.
  static String formatDiscount(int discountPercent) {
    if (discountPercent <= 0) return '';
    return '-$discountPercent%';
  }

  /// Calculates and formats the discount percentage between original and sale price.
  ///
  /// Example: `formatDiscountFromPrices(200000, 160000)` → `'-20%'`
  ///
  /// Returns an empty string if [originalPrice] is zero or sale price >= original.
  static String formatDiscountFromPrices(int originalPrice, int salePrice) {
    if (originalPrice <= 0 || salePrice >= originalPrice) return '';
    final percent = ((originalPrice - salePrice) / originalPrice * 100).round();
    return formatDiscount(percent);
  }

  /// Formats a price range in Vietnamese Dong.
  ///
  /// Example: `formatPriceRange(500000, 1500000)` → `'500.000₫ - 1.500.000₫'`
  ///
  /// If [minPrice] equals [maxPrice], returns a single formatted price.
  static String formatPriceRange(int minPrice, int maxPrice) {
    if (minPrice == maxPrice) {
      return formatVND(minPrice);
    }
    return '${formatVND(minPrice)} - ${formatVND(maxPrice)}';
  }

  /// Formats a price with the original price struck through (for display logic).
  ///
  /// Returns a record with the sale and original formatted prices.
  ///
  /// Example:
  /// ```dart
  /// final (sale, original) = PriceFormatter.formatSalePrice(160000, 200000);
  /// // sale = '160.000₫', original = '200.000₫'
  /// ```
  static ({String salePrice, String originalPrice}) formatSalePrice(
    int salePrice,
    int originalPrice,
  ) {
    return (
      salePrice: formatVND(salePrice),
      originalPrice: formatVND(originalPrice),
    );
  }

  /// Formats a compact price for limited display space.
  ///
  /// Examples:
  /// - `formatCompact(1500000)` → `'1.5tr'`
  /// - `formatCompact(500000)` → `'500k'`
  /// - `formatCompact(50000)` → `'50.000₫'`
  static String formatCompact(int price) {
    if (price >= 1000000) {
      final millions = price / 1000000;
      final formatted = millions == millions.roundToDouble()
          ? '${millions.toInt()}tr'
          : '${(millions * 10).round() / 10}tr';
      return formatted;
    }
    if (price >= 100000) {
      return '${price ~/ 1000}k';
    }
    return formatVND(price);
  }
}
