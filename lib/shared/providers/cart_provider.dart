import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_shopping_chatbot/features/cart/data/models/cart_item_model.dart';
import 'package:smart_shopping_chatbot/features/cart/data/repositories/cart_repository.dart';

class CartProvider with ChangeNotifier {
  final CartRepository _cartRepository;

  CartProvider({CartRepository? cartRepository})
    : _cartRepository = cartRepository ?? CartRepository();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalPrice {
    return _items.fold(
      0,
      (total, item) => total + (item.price * item.quantity),
    );
  }

  int get totalItems {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  Future<void> fetchCart() async {
    _setLoading(true);
    try {
      final response = await _cartRepository.getCartItems();
      _items = response.items;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(int productVariantId, int quantity) async {
    _setLoading(true);
    try {
      await _cartRepository.addToCart(productVariantId, quantity);
      await fetchCart(); // Refresh cart to get accurate server state
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    // Optimistic update
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final oldItem = _items[index];
      _items[index] = oldItem.copyWith(quantity: newQuantity);
      notifyListeners();

      try {
        await _cartRepository.updateCartItem(cartItemId, newQuantity);
      } catch (e) {
        // Revert on failure
        _items[index] = oldItem;
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    // Optimistic update
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final removedItem = _items.removeAt(index);
      notifyListeners();

      try {
        await _cartRepository.removeCartItem(cartItemId);
      } catch (e) {
        // Revert on failure
        _items.insert(index, removedItem);
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

final cartProvider = ChangeNotifierProvider<CartProvider>((ref) {
  return CartProvider();
});
