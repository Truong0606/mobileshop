import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/features/products/data/models/variant_model.dart';
import 'package:smart_shopping_chatbot/features/products/data/repositories/product_repository.dart';
import 'package:smart_shopping_chatbot/shared/providers/auth_provider.dart';
import 'package:smart_shopping_chatbot/shared/providers/cart_provider.dart';
import 'package:smart_shopping_chatbot/shared/providers/product_provider.dart';
import 'package:smart_shopping_chatbot/shared/widgets/app_notification.dart';
import 'package:smart_shopping_chatbot/core/utils/ai_tracking_storage.dart';

class RichTextMessage extends ConsumerWidget {
  final String text;
  final bool isDark;
  final bool isUser;
  final String? conversationId;

  const RichTextMessage({
    super.key,
    required this.text,
    required this.isDark,
    required this.isUser,
    this.conversationId,
  });

  String? _addToCartSkuFromUrl(String url) {
    final match = RegExp(
      r'(?:^|#)/?add-to-cart/([^/?#]+)$',
      caseSensitive: false,
    ).firstMatch(url);
    if (match == null) return null;

    try {
      return Uri.decodeComponent(match.group(1)!);
    } on FormatException {
      return null;
    }
  }

  Future<bool> _handleLinkTap(
    BuildContext context,
    WidgetRef ref,
    String url,
  ) async {
    final sku = _addToCartSkuFromUrl(url);
    if (sku == null) return false;

    if (!ref.read(authProvider).isLoggedIn) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ.'),
          ),
        );
        context.pushNamed('login');
      }
      return true;
    }

    try {
      final variant = await ProductRepository().findVariantBySku(sku);
      if (!context.mounted) return true;

      if (variant == null) {
        _showMessage(context, 'Không tìm thấy sản phẩm có mã $sku.', isError: true);
      } else if (!variant.isActive || !variant.inStock) {
        _showMessage(context, '${variant.productName} hiện đã hết hàng.', isError: true);
      } else {
        await ref.read(cartProvider).addToCart(
          variant.id,
          1,
          source: 'Chat',
          conversationId: conversationId,
        );
        // Lưu lại conversationId để tracking chuyển đổi AI
        await AiTrackingStorage.saveConversationId(conversationId);
        if (context.mounted) {
          _showMessage(context, 'Đã thêm ${variant.productName} vào giỏ hàng.');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          'Không thể thêm sản phẩm vào giỏ. Vui lòng thử lại.',
          isError: true,
        );
      }
    }

    return true;
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    AppNotification.show(
      context,
      message: message,
      type: isError ? NotificationType.error : NotificationType.success,
    );
  }

  String _extractImageIdentifier(String url) {
    if (url.isEmpty) return '';
    try {
      final clean = url.split('?').first.split('#').first;
      final segments = clean.split('/').where((s) => s.isNotEmpty).toList();
      final last = segments.isNotEmpty ? segments.last : '';
      return last.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '').trim().toLowerCase();
    } catch (_) {
      return '';
    }
  }

  String _cleanText(String str) {
    return str
        .toLowerCase()
        .replaceAll(RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()—+\[\]]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _handleImageTap(
    BuildContext context,
    WidgetRef ref,
    String src,
    String alt,
  ) async {
    try {
      // 1. Lấy danh sách variants đã có trong provider hoặc fetch toàn bộ từ repository
      List<VariantModel> variants = ref.read(variantListProvider).variants;
      if (variants.isEmpty || variants.length < 50) {
        variants = await ProductRepository().getAllVariants(pageSize: 100);
      }

      VariantModel? match;
      int? targetProductId;

      // Ưu tiên 1: Trích xuất SKU từ text tin nhắn nếu có (liên kết add-to-cart)
      final skuInText = RegExp(
        r'(?:^|#|/)\/?add-to-cart/([^)\s"'"'"'#]+)',
        caseSensitive: false,
      ).firstMatch(text);
      if (skuInText != null) {
        final extractedSku = Uri.decodeComponent(skuInText.group(1)!).trim().toLowerCase();
        match = variants.where((v) => v.sku.trim().toLowerCase() == extractedSku).firstOrNull;
        match ??= await ProductRepository().findVariantBySku(extractedSku);
        if (match != null) {
          targetProductId = match.productId;
        }
      }

      // Ưu tiên 2: Khớp theo mã định danh ảnh (Cloudinary public ID / tên file ảnh)
      if (match == null && src.isNotEmpty) {
        final srcId = _extractImageIdentifier(src);
        if (srcId.length >= 4) {
          match = variants.where((v) {
            return v.imageUrls.any((img) {
              final imgId = _extractImageIdentifier(img);
              return imgId == srcId || img.contains(src) || src.contains(img);
            });
          }).firstOrNull;
          if (match != null) {
            targetProductId = match.productId;
          }
        }
      }

      // Ưu tiên 3: Khớp theo URL ảnh gốc
      if (match == null && src.isNotEmpty) {
        final cleanSrc = src.split('?').first.toLowerCase();
        match = variants.where((v) {
          return v.imageUrls.any((img) => img.split('?').first.toLowerCase() == cleanSrc);
        }).firstOrNull;
        if (match != null) {
          targetProductId = match.productId;
        }
      }

      // Ưu tiên 4: Khớp theo alt text hoặc tên sản phẩm
      if (match == null && alt.isNotEmpty) {
        final cleanAlt = _cleanText(alt);
        if (cleanAlt.length >= 3) {
          // 4a. Khớp chính xác tên biến thể
          match = variants.where((v) => _cleanText(v.variantName) == cleanAlt).firstOrNull;

          // 4b. Khớp chính xác tên sản phẩm
          match ??= variants.where((v) => _cleanText(v.productName) == cleanAlt).firstOrNull;

          // 4c. Khớp chuỗi con nếu alt đủ dài (từ 5 ký tự trở lên)
          if (match == null && cleanAlt.length >= 5) {
            match = variants.where((v) {
              final pName = _cleanText(v.productName);
              return pName.length >= 5 && (pName.contains(cleanAlt) || cleanAlt.contains(pName));
            }).firstOrNull;
          }
          if (match != null) {
            targetProductId = match.productId;
          }
        }
      }

      // Ưu tiên 5: Quét tên sản phẩm xuất hiện trong text tin nhắn
      if (match == null && targetProductId == null) {
        final cleanMsg = _cleanText(text);
        final candidates = variants.where((v) {
          final pName = _cleanText(v.productName);
          return pName.length >= 6 && cleanMsg.contains(pName);
        }).toList();

        if (candidates.isNotEmpty) {
          candidates.sort((a, b) => b.productName.length.compareTo(a.productName.length));
          match = candidates.first;
          targetProductId = match.productId;
        }
      }

      if (!context.mounted) return;

      if (targetProductId != null) {
        await AiTrackingStorage.saveConversationId(conversationId);
        if (!context.mounted) return;
        context.pushNamed(
          'productDetail',
          pathParameters: {'id': targetProductId.toString()},
          extra: match,
        );
      } else {
        _showMessage(context, 'Không tìm thấy thông tin sản phẩm.', isError: true);
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Không thể mở chi tiết sản phẩm.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Chuyển đổi Markdown -> HTML
    // Sử dụng githubFlavored để hỗ trợ table, strikethrough, autolink...
    final htmlData = md.markdownToHtml(
      text,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );

    // 2. Định nghĩa màu chữ dựa trên người gửi và theme
    final textColor = isUser
        ? AppColors.userBubbleText
        : (isDark ? AppColors.botBubbleTextDark : AppColors.botBubbleTextLight);

    // 3. Sử dụng HtmlWidget để render HTML
    return HtmlWidget(
      // Bọc thêm thẻ div với style cơ bản nếu cần,
      // nhưng HtmlWidget đã hỗ trợ textStyle.
      htmlData,
      textStyle: GoogleFonts.inter(fontSize: 14, height: 1.4, color: textColor),
      // Cấu hình custom style cho các thẻ HTML đặc biệt
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {
            'color': isDark ? '#64B5F6' : '#1976D2',
            'text-decoration': 'none',
          };
        }
        if (element.localName == 'th') {
          return {
            'background-color': isDark ? '#333333' : '#E0E0E0',
            'padding': '8px',
            'border': '1px solid ${isDark ? '#444' : '#ccc'}',
          };
        }
        if (element.localName == 'td') {
          return {
            'padding': '8px',
            'border': '1px solid ${isDark ? '#444' : '#ccc'}',
          };
        }
        if (element.localName == 'table') {
          return {'border-collapse': 'collapse', 'width': '100%'};
        }
        if (element.localName == 'code') {
          return {
            'background-color': isDark ? '#333333' : '#F5F5F5',
            'padding': '2px 4px',
            'border-radius': '4px',
            'font-family': 'monospace',
          };
        }
        if (element.localName == 'pre') {
          return {
            'background-color': isDark ? '#222222' : '#F5F5F5',
            'padding': '8px',
            'border-radius': '8px',
            'overflow': 'auto',
          };
        }
        return null;
      },
      // Cấu hình hiển thị ảnh, video nếu có (tuỳ chọn)
      onErrorBuilder: (context, element, error) =>
          Text('$element error: $error'),
      onLoadingBuilder: (context, element, loadingProgress) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      // Giới hạn chiều rộng ảnh hoặc custom widget nếu cần
      onTapUrl: (url) => _handleLinkTap(context, ref, url),
      customWidgetBuilder: (element) {
        if (element.localName == 'img') {
          final src = element.attributes['src'] ?? '';
          final alt = element.attributes['alt'] ?? '';

          if (src.isNotEmpty) {
            return GestureDetector(
              onTap: () => _handleImageTap(context, ref, src, alt),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: src,
                  placeholder: (context, url) => const SizedBox(
                    height: 150,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        }
        return null;
      },
    );
  }
}
