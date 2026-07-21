import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';

class RichTextMessage extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool isUser;

  const RichTextMessage({
    super.key,
    required this.text,
    required this.isDark,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
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
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        height: 1.4,
        color: textColor,
      ),
      // Cấu hình custom style cho các thẻ HTML đặc biệt
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {'color': isDark ? '#64B5F6' : '#1976D2', 'text-decoration': 'none'};
        }
        if (element.localName == 'th') {
          return {
            'background-color': isDark ? '#333333' : '#E0E0E0',
            'padding': '8px',
            'border': '1px solid ${isDark ? '#444' : '#ccc'}'
          };
        }
        if (element.localName == 'td') {
          return {
            'padding': '8px',
            'border': '1px solid ${isDark ? '#444' : '#ccc'}'
          };
        }
        if (element.localName == 'table') {
          return {
            'border-collapse': 'collapse',
            'width': '100%',
          };
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
      onLoadingBuilder: (context, element, loadingProgress) =>
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      // Giới hạn chiều rộng ảnh hoặc custom widget nếu cần
      customWidgetBuilder: (element) {
        // Có thể bổ sung chặn custom widget ở đây
        return null;
      },
    );
  }
}
