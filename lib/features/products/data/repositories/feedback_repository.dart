import 'package:smart_shopping_chatbot/core/network/api_client.dart';
import 'package:smart_shopping_chatbot/core/network/paginated_response.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/feedback_model.dart';

class FeedbackRepository {
  final ApiClient _apiClient;

  FeedbackRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<PaginatedResponse<FeedbackModel>> getProductFeedbacks(
    int productId, {
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final response = await _apiClient.get(
      '/feedbacks/product/$productId',
      queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
    );

    final data = response.data['data'];
    return PaginatedResponse.fromJson(
      data,
      (json) => FeedbackModel.fromJson(json),
    );
  }

  Future<FeedbackModel> submitFeedback({
    required String accountId,
    required int productId,
    required int rating,
    required String comment,
  }) async {
    final response = await _apiClient.post(
      '/feedbacks',
      data: {
        'accountId': accountId,
        'productId': productId,
        'rating': rating,
        'comment': comment,
      },
    );

    if (response.data['data'] != null && response.data['data'] is Map) {
      return FeedbackModel.fromJson(response.data['data']);
    }

    // Fallback if full object is not returned
    return FeedbackModel(
      id: 0,
      accountId: accountId,
      accountName: 'You',
      productId: productId,
      productName: '',
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
  }
}
