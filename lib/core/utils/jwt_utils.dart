import 'dart:convert';

/// Utility class for decoding JWT tokens without external dependencies.
///
/// A JWT token has 3 parts separated by dots: `header.payload.signature`.
/// This class decodes the payload (middle part) which is base64url-encoded JSON.
class JwtUtils {
  JwtUtils._();

  /// Decodes the payload section of a JWT token and returns it as a Map.
  ///
  /// Returns an empty map if the token is malformed or cannot be decoded.
  static Map<String, dynamic> decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      // The payload is the second part
      final payload = parts[1];

      // Base64url decode (add padding if necessary)
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Extracts the user role from a JWT token.
  ///
  /// Looks for the `role` claim in the payload.
  /// Returns `null` if the claim is not found or the token is invalid.
  static String? extractRole(String token) {
    final payload = decodePayload(token);
    // Support common claim names
    return payload['role'] as String? ??
        payload['roles'] as String? ??
        (payload['role'] is List ? (payload['role'] as List).first?.toString() : null);
  }

  /// Checks whether the JWT token has expired based on the `exp` claim.
  ///
  /// Returns `true` if expired or if the `exp` claim is missing.
  static bool isExpired(String token) {
    final payload = decodePayload(token);
    final exp = payload['exp'];
    if (exp == null) return true;

    final expDate = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expDate);
  }
}
