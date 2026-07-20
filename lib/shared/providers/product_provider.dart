import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_shopping_chatbot/core/network/api_exceptions.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/product_model.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/variant_model.dart';
import 'package:smart_shopping_chatbot/features/products/data/repositories/product_repository.dart';

/// State for the product list.
class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  ProductListState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool clearError = false,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Manages product list state with real API calls.
class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier({ProductRepository? repository})
    : _repository = repository ?? ProductRepository(),
      super(const ProductListState());

  final ProductRepository _repository;

  Future<void> fetchProducts({int pageSize = 10}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getProducts(
        pageIndex: 1,
        pageSize: pageSize,
      );
      state = ProductListState(
        products: response.items,
        currentPage: response.pageIndex,
        totalPages: response.totalPages,
        hasMore: response.hasMore,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải sản phẩm: ${e.toString()}',
      );
    }
  }

  Future<void> loadMore({int pageSize = 10}) async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getProducts(
        pageIndex: nextPage,
        pageSize: pageSize,
      );
      state = state.copyWith(
        products: [...state.products, ...response.items],
        isLoading: false,
        currentPage: response.pageIndex,
        totalPages: response.totalPages,
        hasMore: response.hasMore,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thêm: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() => fetchProducts();
}

/// Global product list provider.
final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>(
      (ref) => ProductListNotifier(),
    );

// ═══════════════════════════════════════════
// Variant List Provider (showcase with prices)
// ═══════════════════════════════════════════

/// State for the variant list (purchasable items with price & images).
class VariantListState {
  final List<VariantModel> variants;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const VariantListState({
    this.variants = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  VariantListState copyWith({
    List<VariantModel>? variants,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool clearError = false,
  }) {
    return VariantListState(
      variants: variants ?? this.variants,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Manages variant list state — fetches purchasable SKUs with price & images.
class VariantListNotifier extends StateNotifier<VariantListState> {
  VariantListNotifier({ProductRepository? repository})
    : _repository = repository ?? ProductRepository(),
      super(const VariantListState());

  final ProductRepository _repository;

  Future<void> fetchVariants({int pageSize = 20}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getVariants(
        pageIndex: 1,
        pageSize: pageSize,
      );
      state = VariantListState(
        variants: response.items,
        currentPage: response.pageIndex,
        totalPages: response.totalPages,
        hasMore: response.hasMore,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải sản phẩm: ${e.toString()}',
      );
    }
  }

  Future<void> loadMore({int pageSize = 20}) async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getVariants(
        pageIndex: nextPage,
        pageSize: pageSize,
      );
      state = state.copyWith(
        variants: [...state.variants, ...response.items],
        isLoading: false,
        currentPage: response.pageIndex,
        totalPages: response.totalPages,
        hasMore: response.hasMore,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thêm: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() => fetchVariants();
}

/// Global variant list provider (showcase items with price, images, attributes).
final variantListProvider =
    StateNotifierProvider<VariantListNotifier, VariantListState>(
      (ref) => VariantListNotifier(),
    );

// ═══════════════════════════════════════════
// Image Map Provider (all product images)
// ═══════════════════════════════════════════

/// State for the image map.
class ImageMapState {
  /// All images, keyed by productId → list of image URLs.
  final Map<int, List<String>> byProductId;

  /// All images, keyed by variantId → list of image URLs.
  final Map<int, List<String>> byVariantId;

  final bool isLoading;
  final String? errorMessage;

  const ImageMapState({
    this.byProductId = const {},
    this.byVariantId = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  /// Get images for a product (all variants combined).
  List<String> getProductImages(int productId) => byProductId[productId] ?? [];

  /// Get images for a specific variant.
  List<String> getVariantImages(int variantId) => byVariantId[variantId] ?? [];

  /// Get the first image for a product, or null.
  String? getProductThumbnail(int productId) {
    final images = byProductId[productId];
    return (images != null && images.isNotEmpty) ? images.first : null;
  }

  /// Get the first image for a variant, or null.
  String? getVariantThumbnail(int variantId) {
    final images = byVariantId[variantId];
    return (images != null && images.isNotEmpty) ? images.first : null;
  }
}

/// Fetches all images and builds lookup maps.
class ImageMapNotifier extends StateNotifier<ImageMapState> {
  ImageMapNotifier({ProductRepository? repository})
    : _repository = repository ?? ProductRepository(),
      super(const ImageMapState());

  final ProductRepository _repository;

  Future<void> fetchAllImages() async {
    state = const ImageMapState(isLoading: true);
    try {
      final images = await _repository.getAllImages();
      final byProduct = <int, List<String>>{};
      final byVariant = <int, List<String>>{};

      for (final img in images) {
        byProduct.putIfAbsent(img.productId, () => []).add(img.imageUrl);
        byVariant.putIfAbsent(img.variantId, () => []).add(img.imageUrl);
      }

      state = ImageMapState(byProductId: byProduct, byVariantId: byVariant);
    } on ApiException catch (e) {
      state = ImageMapState(errorMessage: e.message);
    } catch (e) {
      state = ImageMapState(
        errorMessage: 'Không thể tải hình ảnh: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() => fetchAllImages();
}

/// Global image map provider.
final imageMapProvider = StateNotifierProvider<ImageMapNotifier, ImageMapState>(
  (ref) => ImageMapNotifier(),
);
