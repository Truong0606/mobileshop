import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/shared/widgets/empty_state_widget.dart';
import 'package:smart_shopping_chatbot/shared/widgets/app_notification.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  // Mock products list
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': '1',
      'name': 'Áo sơ mi nam',
      'price': '250.000 đ',
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'id': '2',
      'name': 'Quần jean nữ',
      'price': '350.000 đ',
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'id': '3',
      'name': 'Giày thể thao nam',
      'price': '500.000 đ',
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'id': '4',
      'name': 'Túi xách thời trang',
      'price': '400.000 đ',
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  late List<Map<String, dynamic>> _wishlist;

  @override
  void initState() {
    super.initState();
    _wishlist = List.from(_mockProducts);
  }

  void _removeFromWishlist(String id) {
    setState(() {
      _wishlist.removeWhere((item) => item['id'] == id);
    });
    
    // Attempting common static show method for notifications, 
    // fallback to ScaffoldMessenger if AppNotification is a widget.
    try {
      AppNotification.show(context, message: 'Đã bỏ yêu thích');
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Yêu thích',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _wishlist.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.favorite_border,
              title: 'Chưa có sản phẩm yêu thích',
              message: 'Hãy thêm sản phẩm vào danh sách để xem lại sau.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: _wishlist.length,
              itemBuilder: (context, index) {
                final product = _wishlist[index];
                return _buildProductCard(product);
              },
            ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    child: Image.network(
                      product['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeFromWishlist(product['id']),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['price'],
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
