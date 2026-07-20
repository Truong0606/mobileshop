/// API response model for variant data from `GET /api/v1/variants`.
///
/// Example JSON:
/// ```json
/// {
///   "id": 1,
///   "productId": 1,
///   "productName": "Oversized Cotton T-shirt",
///   "productDescription": "Soft oversized cotton T-shirt for daily wear",
///   "variantName": "Black Oversized Cotton T-shirt - Size M",
///   "price": 199000,
///   "stockQuantity": 50,
///   "sku": "TSHIRT-OVERSIZED-BLACK-M",
///   "weightGrams": 250,
///   "imageUrl": ["https://res.cloudinary.com/.../adoms4ffxktx21xqjqja.jpg"],
///   "status": "Active",
///   "createdAt": "2026-06-06T09:46:49.679897Z",
///   "updatedAt": null,
///   "variantAttributes": [
///     { "attributeId": 1, "attributeName": "Color", "attributeCode": "color",
///       "values": [{ "valueText": "Black", "slug": "black" }] },
///     { "attributeId": 2, "attributeName": "Size", "attributeCode": "size",
///       "values": [{ "valueText": "M", "slug": "m" }] }
///   ]
/// }
/// ```
class VariantModel {
  final int id;
  final int productId;
  final String productName;
  final String productDescription;
  final String variantName;
  final double price;
  final int stockQuantity;
  final String sku;
  final int weightGrams;
  final List<String> imageUrls;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final List<VariantAttribute> attributes;

  const VariantModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.variantName,
    required this.price,
    required this.stockQuantity,
    required this.sku,
    required this.weightGrams,
    required this.imageUrls,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.attributes,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    // Parse image URLs — can be a list of strings
    final rawImages = json['imageUrl'];
    final List<String> images;
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (rawImages is String) {
      images = [rawImages];
    } else {
      images = [];
    }

    // Parse variant attributes
    final rawAttrs = json['variantAttributes'] as List<dynamic>? ?? [];
    final attrs = rawAttrs
        .map((e) => VariantAttribute.fromJson(e as Map<String, dynamic>))
        .toList();

    return VariantModel(
      id: json['id'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      productDescription: json['productDescription'] as String? ?? '',
      variantName: json['variantName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      sku: json['sku'] as String? ?? '',
      weightGrams: json['weightGrams'] as int? ?? 0,
      imageUrls: images,
      status: json['status'] as String? ?? 'Active',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      attributes: attrs,
    );
  }

  /// First image URL or null.
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Whether this variant is currently active.
  bool get isActive => status == 'Active';

  /// Whether this variant is in stock.
  bool get inStock => stockQuantity > 0;

  /// Get attribute value by code (e.g., "color", "size").
  String? getAttributeValue(String code) {
    for (final attr in attributes) {
      if (attr.attributeCode == code && attr.values.isNotEmpty) {
        return attr.values.first.valueText;
      }
    }
    return null;
  }

  /// Formatted price in VND.
  String get formattedPrice {
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

/// An attribute attached to a variant (e.g., Color → Black).
class VariantAttribute {
  final int attributeId;
  final String attributeName;
  final String attributeCode;
  final List<AttributeValueItem> values;

  const VariantAttribute({
    required this.attributeId,
    required this.attributeName,
    required this.attributeCode,
    required this.values,
  });

  factory VariantAttribute.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'] as List<dynamic>? ?? [];
    return VariantAttribute(
      attributeId: json['attributeId'] as int? ?? 0,
      attributeName: json['attributeName'] as String? ?? '',
      attributeCode: json['attributeCode'] as String? ?? '',
      values: rawValues
          .map((e) => AttributeValueItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single attribute value (e.g., "Black" with slug "black").
class AttributeValueItem {
  final String valueText;
  final String slug;

  const AttributeValueItem({required this.valueText, required this.slug});

  factory AttributeValueItem.fromJson(Map<String, dynamic> json) {
    return AttributeValueItem(
      valueText: json['valueText'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}
