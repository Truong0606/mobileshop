/// API response model for image data from `GET /api/v1/images`.
///
/// Example JSON:
/// ```json
/// {
///   "imageUrl": "https://res.cloudinary.com/shuppe/image/upload/v.../products/abc.jpg",
///   "productId": 1,
///   "variantId": 1
/// }
/// ```
class ImageModel {
  final String imageUrl;
  final int productId;
  final int variantId;

  const ImageModel({
    required this.imageUrl,
    required this.productId,
    required this.variantId,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      imageUrl: json['imageUrl'] as String? ?? '',
      productId: json['productId'] as int? ?? 0,
      variantId: json['variantId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'productId': productId,
    'variantId': variantId,
  };
}
