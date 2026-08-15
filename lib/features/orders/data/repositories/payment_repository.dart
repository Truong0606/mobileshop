import 'package:smart_shopping_chatbot/core/network/api_client.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<String?> checkout({
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required String returnUrl,
    required String cancelUrl,
    String? conversationId,
  }) async {
    final Map<String, dynamic> body = {
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'shippingAddress': shippingAddress,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversationId'] = conversationId;
    }

    final response = await _apiClient.post(
      '/payments',
      data: body,
    );

    final root = response.data;
    if (root == null) return null;

    if (root is String && (root.startsWith('http://') || root.startsWith('https://'))) {
      return root;
    }

    if (root is Map) {
      final data = root['data'];
      if (data is String && (data.startsWith('http://') || data.startsWith('https://'))) {
        return data;
      }
      if (data is Map) {
        final url = data['paymentUrl'] ?? data['checkoutUrl'] ?? data['url'];
        if (url != null && url.toString().isNotEmpty) {
          return url.toString();
        }
      }
      final rootUrl = root['paymentUrl'] ?? root['checkoutUrl'] ?? root['url'];
      if (rootUrl != null && rootUrl.toString().isNotEmpty) {
        return rootUrl.toString();
      }
    }

    // Đặt hàng thành công nhưng backend không trả paymentUrl
    return null;
  }
}
