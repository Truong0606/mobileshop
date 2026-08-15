class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final int productVariantId;
  final String variantName;
  final String productVariantName;
  final int quantity;
  final double unitPrice;
  final double price;
  final String? imageUrl;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productVariantId,
    required this.variantName,
    required this.productVariantName,
    required this.quantity,
    required this.unitPrice,
    required this.price,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawVariantName = (json['productVariantName'] ??
            json['variantName'] ??
            json['productName'] ??
            '')
        .toString();

    final rawUnitPrice = (json['unitPrice'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;

    return OrderItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      productName: (json['productName'] ?? rawVariantName).toString(),
      productVariantId:
          json['productVariantId'] as int? ?? (json['id'] as int? ?? 0),
      variantName: rawVariantName,
      productVariantName: rawVariantName,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: rawUnitPrice,
      price: rawUnitPrice,
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
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentCode;
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
    this.paymentMethod,
    this.paymentStatus,
    this.paymentCode,
    this.paymentUrl,
    this.orderCode,
    this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItemsList = (json['orderItems'] ?? json['items']) as List? ?? [];
    final parsedItems = rawItemsList
        .map((itemJson) =>
            OrderItemModel.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    double total = (json['totalAmount'] as num?)?.toDouble() ?? 0.0;
    if (total == 0.0 && parsedItems.isNotEmpty) {
      total = parsedItems.fold(
          0.0, (sum, item) => sum + (item.price * item.quantity));
    }

    final rawStatus =
        (json['paymentStatus'] ?? json['status'] ?? 'PENDING').toString();
    final paymentCode = (json['paymentCode'] ??
            json['orderCode'] ??
            json['id']?.toString())
        ?.toString();

    return OrderModel(
      id: json['id'] as int? ??
          int.tryParse(json['orderId']?.toString() ?? '') ??
          0,
      accountId: json['accountId']?.toString(),
      receiverName: json['receiverName'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      shippingAddress: json['shippingAddress'] as String? ?? '',
      note: json['note'] as String?,
      totalAmount: total,
      status: rawStatus,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      paymentCode: paymentCode,
      paymentUrl: json['paymentUrl'] as String?,
      orderCode: paymentCode,
      createdAt: json['createdAt'] as String?,
      items: parsedItems,
    );
  }
}
