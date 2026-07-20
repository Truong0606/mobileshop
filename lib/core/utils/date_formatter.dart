/// Date and time formatting utilities for the shopping chatbot.
///
/// Provides human-readable relative time strings for chat messages
/// and standardized date formats for product information.
library;

import 'package:intl/intl.dart';

/// Utility class for formatting dates and times throughout the app.
abstract final class DateFormatter {
  /// Formats a [DateTime] into a human-readable relative time string
  /// suitable for chat message timestamps.
  ///
  /// Returns:
  /// - `'Vừa xong'` for times within the last 60 seconds
  /// - `'Xm trước'` for times within the last hour (e.g., `'5m trước'`)
  /// - `'Xg trước'` for times within the last 24 hours (e.g., `'2g trước'`)
  /// - `'Hôm qua HH:mm'` for yesterday
  /// - `'dd/MM/yyyy'` for older dates
  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return DateFormat('HH:mm').format(dateTime);
    }

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m trước';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}g trước';
    }

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == yesterday) {
      return 'Hôm qua ${DateFormat('HH:mm').format(dateTime)}';
    }

    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  /// Formats a [DateTime] for product display (e.g., listing date, review date).
  ///
  /// Returns a string like `'02/06/2026'` or `'02 Th06 2026'` depending
  /// on whether [abbreviated] is true.
  static String formatProductDate(
    DateTime dateTime, {
    bool abbreviated = false,
  }) {
    if (abbreviated) {
      return DateFormat('dd MMM yyyy', 'vi_VN').format(dateTime);
    }
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  /// Formats a [DateTime] as a full date-time string.
  ///
  /// Returns a string like `'02/06/2026 08:30'`.
  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Formats a [DateTime] as time only.
  ///
  /// Returns a string like `'08:30'`.
  static String formatTimeOnly(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Returns a chat-section header string for grouping messages by date.
  ///
  /// Returns:
  /// - `'Hôm nay'` for today's date
  /// - `'Hôm qua'` for yesterday
  /// - `'dd/MM/yyyy'` for older dates
  static String formatChatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (dateOnly == yesterday) {
      return 'Hôm qua';
    }

    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
