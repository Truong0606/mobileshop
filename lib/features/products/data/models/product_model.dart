/// API response model for product data from `GET /api/v1/products`.
///
/// Maps to the server JSON:
/// ```json
/// {
///   "id": 1,
///   "name": "Oversized Cotton T-shirt",
///   "brand": "ShoppeFake Fashion",
///   "description": "Soft oversized cotton T-shirt for daily wear",
///   "slug": "oversized-cotton-t-shirt",
///   "status": "Active",
///   "createdAt": "2026-06-06T09:44:10.8847882",
///   "updatedAt": null,
///   "categoryName": "T-shirts"
/// }
/// ```
class ProductModel {
  final int id;
  final String name;
  final String brand;
  final String description;
  final String slug;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String categoryName;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.slug,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      description: json['description'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      categoryName: json['categoryName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'description': description,
    'slug': slug,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'categoryName': categoryName,
  };

  bool get isActive => status == 'Active';
}
