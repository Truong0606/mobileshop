class CartItemModel {
  final int id;
  final int productVariantId;
  final String variantName;
  final String productName;
  final double price;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.productVariantId,
    required this.variantName,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int? ?? 0,
      productVariantId: json['productVariantId'] as int? ?? 0,
      variantName: json['variantName'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productVariantId': productVariantId,
      'variantName': variantName,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    int? id,
    int? productVariantId,
    String? variantName,
    String? productName,
    double? price,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productVariantId: productVariantId ?? this.productVariantId,
      variantName: variantName ?? this.variantName,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
