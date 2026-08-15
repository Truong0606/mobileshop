class OrderItemModel {
  final int productId;
  final String productName;
  final int productVariantId;
  final String variantName;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productVariantId,
    required this.variantName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      productVariantId: json['productVariantId'] as int? ?? 0,
      variantName: json['variantName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class OrderModel {
  final int id;
  final String? accountId;
  final String receiverName;
  final String receiverPhone;
  final String shippingAddress;
  final String? note;
  final double totalAmount;
  final String status;
  final String? paymentUrl;
  final String? orderCode;
  final String? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    this.accountId,
    required this.receiverName,
    required this.receiverPhone,
    required this.shippingAddress,
    this.note,
    required this.totalAmount,
    required this.status,
    this.paymentUrl,
    this.orderCode,
    this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItemModel> parsedItems = itemsList
        .map((itemJson) => OrderItemModel.fromJson(itemJson))
        .toList();

    return OrderModel(
      id: json['id'] as int? ?? 0,
      accountId: json['accountId'] as String?,
      receiverName: json['receiverName'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      shippingAddress: json['shippingAddress'] as String? ?? '',
      note: json['note'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Pending',
      paymentUrl: json['paymentUrl'] as String?,
      orderCode: json['orderCode'] as String?,
      createdAt: json['createdAt'] as String?,
      items: parsedItems,
    );
  }
}
