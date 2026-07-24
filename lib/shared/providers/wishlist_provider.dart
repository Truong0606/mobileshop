import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistItem {
  final int productId;
  final String name;
  final double price;
  final String imageUrl;

  WishlistItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
      };

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        productId: json['productId'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
      );
}

class WishlistNotifier extends StateNotifier<List<WishlistItem>> {
  WishlistNotifier() : super([]) {
    _loadWishlist();
  }

  static const _key = 'wishlist_items';

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList.map((e) => WishlistItem.fromJson(e)).toList();
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((e) => e.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  void toggleFavorite(WishlistItem item) {
    if (isFavorite(item.productId)) {
      state = state.where((e) => e.productId != item.productId).toList();
    } else {
      state = [...state, item];
    }
    _saveWishlist();
  }

  bool isFavorite(int productId) {
    return state.any((item) => item.productId == productId);
  }

  void removeFavorite(int productId) {
    state = state.where((e) => e.productId != productId).toList();
    _saveWishlist();
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<WishlistItem>>((ref) {
  return WishlistNotifier();
});
