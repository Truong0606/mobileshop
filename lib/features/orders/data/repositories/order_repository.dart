import 'package:smart_shopping_chatbot/core/network/api_client.dart';
import 'package:smart_shopping_chatbot/core/network/paginated_response.dart';
import 'package:smart_shopping_chatbot/features/orders/data/models/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<PaginatedResponse<OrderModel>> getOrders({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/orders',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );

    return PaginatedResponse.fromJson(
      response.data,
      (json) => OrderModel.fromJson(json),
    );
  }

  Future<OrderModel> getOrderById(int id) async {
    final response = await _apiClient.get('/orders/$id');
    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data);
  }
}
