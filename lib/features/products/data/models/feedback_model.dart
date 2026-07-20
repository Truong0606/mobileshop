class FeedbackModel {
  final int id;
  final String accountId;
  final String accountName;
  final int productId;
  final String productName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.productId,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as int? ?? 0,
      accountId: json['accountId'] as String? ?? '',
      accountName: json['accountName'] as String? ?? 'Unknown',
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'accountName': accountName,
      'productId': productId,
      'productName': productName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
