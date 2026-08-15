import 'package:smart_shopping_chatbot/core/network/api_client.dart';
import 'package:smart_shopping_chatbot/core/network/paginated_response.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/image_model.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/product_model.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/variant_model.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/category_model.dart';

/// Repository for product, variant, and image API calls.
class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  // ───────── Categories ─────────

  /// Fetch all categories.
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/categories');

    final paginated = PaginatedResponse.fromJson(
      response.data!,
      (json) => CategoryModel.fromJson(json),
    );

    return paginated.items;
  }

  // ───────── Products ─────────

  /// Fetch paginated products.
  ///
  /// `GET /products?pageIndex={page}&pageSize={size}`
  Future<PaginatedResponse<ProductModel>> getProducts({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
    );

    return PaginatedResponse.fromJson(response.data!, ProductModel.fromJson);
  }

  /// Fetch a single product by ID.
  ///
  /// `GET /products/{id}`
  Future<ProductModel> getProductById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/products/$id',
    );

    final data = response.data!;
    final productJson = data.containsKey('data')
        ? data['data'] as Map<String, dynamic>
        : data;

    return ProductModel.fromJson(productJson);
  }

  // ───────── Variants ─────────

  /// Fetch paginated variants (the real purchasable items with price & images).
  ///
  /// `GET /variants?pageIndex={page}&pageSize={size}`
  Future<PaginatedResponse<VariantModel>> getVariants({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/variants',
      queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
    );

    return PaginatedResponse.fromJson(response.data!, VariantModel.fromJson);
  }

  /// Fetch a single variant by ID.
  ///
  /// `GET /variants/{id}`
  Future<VariantModel> getVariantById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/variants/$id',
    );

    final data = response.data!;
    final variantJson = data.containsKey('data')
        ? data['data'] as Map<String, dynamic>
        : data;

    return VariantModel.fromJson(variantJson);
  }

  /// Resolves the SKU emitted in an AI add-to-cart link to a variant.
  ///
  /// The public API is paginated and has no lookup-by-SKU endpoint, so search
  /// until the whole catalogue has been covered.
  Future<VariantModel?> findVariantBySku(String sku) async {
    final normalizedSku = sku.trim().toLowerCase();
    if (normalizedSku.isEmpty) return null;

    const pageSize = 100;
    var pageIndex = 1;
    while (true) {
      final page = await getVariants(pageIndex: pageIndex, pageSize: pageSize);
      for (final variant in page.items) {
        if (variant.sku.trim().toLowerCase() == normalizedSku) {
          return variant;
        }
      }

      if (!page.hasMore || page.items.isEmpty) return null;
      pageIndex += 1;
    }
  }

  // ───────── Images ─────────

  /// Fetch paginated images.
  ///
  /// `GET /images?pageIndex={page}&pageSize={size}`
  Future<PaginatedResponse<ImageModel>> getImages({
    int pageIndex = 1,
    int pageSize = 50,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/images',
      queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
    );

    return PaginatedResponse.fromJson(response.data!, ImageModel.fromJson);
  }

  /// Fetch ALL images across all pages.
  ///
  /// Returns a flat list of every [ImageModel] in the database.
  Future<List<ImageModel>> getAllImages() async {
    final List<ImageModel> allImages = [];
    int currentPage = 1;
    bool hasMore = true;

    while (hasMore) {
      final response = await getImages(pageIndex: currentPage, pageSize: 50);
      allImages.addAll(response.items);
      hasMore = response.hasMore;
      currentPage++;
    }

    return allImages;
  }
}
