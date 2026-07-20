/// Input validation utilities for forms and search queries.
///
/// Each validator returns `null` on success or a Vietnamese error message
/// string on failure, following Flutter's [FormField] validator convention.
library;

/// Utility class providing reusable input validators.
abstract final class Validators {
  /// Validates an email address.
  ///
  /// Returns `null` if valid, or an error message if:
  /// - The value is empty
  /// - The format does not match a standard email pattern
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }

    final trimmed = value.trim();

    // RFC 5322 simplified pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  /// Validates a password.
  ///
  /// Returns `null` if valid, or an error message if:
  /// - The value is empty
  /// - Shorter than [minLength] characters (default: 8)
  /// - Missing an uppercase letter
  /// - Missing a digit
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < minLength) {
      return 'Mật khẩu phải có ít nhất $minLength ký tự';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ hoa';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }

    return null;
  }

  /// Validates a display name or full name.
  ///
  /// Returns `null` if valid, or an error message if:
  /// - The value is empty
  /// - Shorter than [minLength] characters (default: 2)
  /// - Longer than [maxLength] characters (default: 50)
  /// - Contains non-letter/space characters
  static String? validateName(
    String? value, {
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên';
    }

    final trimmed = value.trim();

    if (trimmed.length < minLength) {
      return 'Tên phải có ít nhất $minLength ký tự';
    }

    if (trimmed.length > maxLength) {
      return 'Tên không được vượt quá $maxLength ký tự';
    }

    // Allow Unicode letters (including Vietnamese diacritics) and spaces
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(trimmed)) {
      return 'Tên chỉ được chứa chữ cái và khoảng trắng';
    }

    return null;
  }

  /// Validates a search query.
  ///
  /// Returns `null` if valid, or an error message if:
  /// - The value is empty or whitespace-only
  /// - Shorter than [minLength] characters (default: 1)
  /// - Longer than [maxLength] characters (default: 200)
  static String? validateSearchQuery(
    String? value, {
    int minLength = 1,
    int maxLength = 200,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập từ khóa tìm kiếm';
    }

    final trimmed = value.trim();

    if (trimmed.length < minLength) {
      return 'Từ khóa phải có ít nhất $minLength ký tự';
    }

    if (trimmed.length > maxLength) {
      return 'Từ khóa không được vượt quá $maxLength ký tự';
    }

    return null;
  }

  /// Validates a phone number (Vietnamese format).
  ///
  /// Returns `null` if valid, or an error message if the format is invalid.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    final trimmed = value.trim().replaceAll(RegExp(r'[\s\-()]'), '');

    // Vietnamese phone: starts with 0 or +84, followed by 9-10 digits
    final phoneRegex = RegExp(r'^(?:\+84|0)\d{9,10}$');

    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Số điện thoại không hợp lệ';
    }

    return null;
  }
}
