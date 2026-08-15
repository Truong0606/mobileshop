import 'package:smart_shopping_chatbot/core/network/api_client.dart';
import 'package:smart_shopping_chatbot/core/network/paginated_response.dart';
import 'package:smart_shopping_chatbot/features/cart/data/models/cart_item_model.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<PaginatedResponse<CartItemModel>> getCartItems({
    int pageIndex = 1,
    int pageSize = 100,
  }) async {
    final response = await _apiClient.get(
      '/cart-items',
      queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
    );

    return PaginatedResponse.fromJson(
      response.data,
      (json) => CartItemModel.fromJson(json),
    );
  }

  Future<CartItemModel> addToCart(
    int productVariantId,
    int quantity, {
    String source = 'Product',
    String? conversationId,
  }) async {
    final effectiveSource = (conversationId != null && conversationId.isNotEmpty)
        ? 'Chat'
        : source;

    final Map<String, dynamic> body = {
      'productVariantId': productVariantId,
      'quantity': quantity,
      'conversationId': (effectiveSource == 'Chat') ? conversationId : null,
    };

    final response = await _apiClient.post(
      '/cart-items',
      queryParameters: {
        'addToCartSource': effectiveSource,
      },
      data: body,
    );

    // The API might just return success or the updated cart item.
    // If it returns the item in 'data', parse it.
    if (response.data['data'] != null && response.data['data'] is Map) {
      return CartItemModel.fromJson(response.data['data']);
    }

    // Fallback if the endpoint only returns success without the full object
    return CartItemModel(
      id: 0,
      productVariantId: productVariantId,
      variantName: '',
      productName: '',
      price: 0,
      quantity: quantity,
      conversationId: (effectiveSource == 'Chat') ? conversationId : null,
      source: effectiveSource,
    );
  }

  Future<CartItemModel> updateCartItem(int id, int quantity) async {
    final response = await _apiClient.put('/cart-items/$id/$quantity');

    if (response.data['data'] != null && response.data['data'] is Map) {
      return CartItemModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to parse updated cart item');
  }

  Future<void> removeCartItem(int id) async {
    await _apiClient.delete('/cart-items/$id');
  }
}
