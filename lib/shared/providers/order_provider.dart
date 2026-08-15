import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_shopping_chatbot/features/orders/data/models/order_model.dart';
import 'package:smart_shopping_chatbot/features/orders/data/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

class OrderState {
  final bool isLoading;
  final String? error;
  final List<OrderModel> orders;
  final bool hasMore;
  final int currentPage;

  OrderState({
    this.isLoading = false,
    this.error,
    this.orders = const [],
    this.hasMore = true,
    this.currentPage = 1,
  });

  OrderState copyWith({
    bool? isLoading,
    String? error,
    List<OrderModel>? orders,
    bool? hasMore,
    int? currentPage,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      orders: orders ?? this.orders,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(OrderState()) {
    fetchOrders(refresh: true);
  }

  Future<void> fetchOrders({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final page = refresh ? 1 : state.currentPage + 1;

    if (refresh) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _repository.getOrders(pageNumber: page, pageSize: 20);
      final newOrders = response.items;

      state = state.copyWith(
        isLoading: false,
        orders: refresh ? newOrders : [...state.orders, ...newOrders],
        hasMore: newOrders.length == 20, // assuming pageSize is 20
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchOrders(refresh: true);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository);
});
