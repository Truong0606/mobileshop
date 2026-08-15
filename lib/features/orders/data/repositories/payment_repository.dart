import 'package:smart_shopping_chatbot/core/network/api_client.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<String> checkout({
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    final response = await _apiClient.post(
      '/payments',
      data: {
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'shippingAddress': shippingAddress,
        'returnUrl': returnUrl,
        'cancelUrl': cancelUrl,
      },
    );

    // API trả về: { "paymentUrl": "https://pay.payos.vn/..." }
    final data = response.data['data'] ?? response.data;
    if (data['paymentUrl'] != null) {
      return data['paymentUrl'] as String;
    }
    throw Exception('Failed to get paymentUrl from server');
  }
}
