/// Paginated API response wrapper.
///
/// The ShoppeFake API wraps all list responses in this format:
/// ```json
/// {
///   "code": 200,
///   "statusCode": "Success",
///   "message": "...",
///   "data": {
///     "items": [...],
///     "totalItems": 10,
///     "pageIndex": 1,
///     "totalPages": 2,
///     "pageSize": 10
///   }
/// }
/// ```
class PaginatedResponse<T> {
  final int code;
  final String statusCode;
  final String message;
  final List<T> items;
  final int totalItems;
  final int pageIndex;
  final int totalPages;
  final int pageSize;

  const PaginatedResponse({
    required this.code,
    required this.statusCode,
    required this.message,
    required this.items,
    required this.totalItems,
    required this.pageIndex,
    required this.totalPages,
    required this.pageSize,
  });

  /// Parse from the full API JSON response.
  ///
  /// [fromJsonItem] converts each item in the `data.items` array.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final itemsList = (data['items'] as List<dynamic>?) ?? [];

    return PaginatedResponse(
      code: json['code'] as int? ?? 0,
      statusCode: json['statusCode'] as String? ?? '',
      message: json['message'] as String? ?? '',
      items: itemsList
          .map((e) => fromJsonItem(e as Map<String, dynamic>))
          .toList(),
      totalItems: data['totalItems'] as int? ?? 0,
      pageIndex: data['pageIndex'] as int? ?? 1,
      totalPages: data['totalPages'] as int? ?? 1,
      pageSize: data['pageSize'] as int? ?? 10,
    );
  }

  bool get hasMore => pageIndex < totalPages;
}
