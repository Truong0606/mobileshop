import 'package:equatable/equatable.dart';

/// Represents a product in the shopping catalog.
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String> images;
  final String category;
  final String brand;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockQuantity;
  final Map<String, String> attributes;
  final Map<String, String> specs;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.images = const [],
    required this.category,
    required this.brand,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.stockQuantity = 0,
    this.attributes = const {},
    this.specs = const {},
  });

  /// Returns the discount percentage if [originalPrice] is set and greater than [price].
  double? get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100);
  }

  /// Whether this product currently has a discount.
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    originalPrice,
    imageUrl,
    images,
    category,
    brand,
    rating,
    reviewCount,
    inStock,
    stockQuantity,
    attributes,
    specs,
  ];
}
