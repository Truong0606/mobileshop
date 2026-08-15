import 'package:shared_preferences/shared_preferences.dart';

/// Helper to store and retrieve the last AI conversation ID
/// for conversion tracking during payment / checkout.
class AiTrackingStorage {
  static const _conversationKey = 'last_ai_conversation_id';

  /// Save the conversationId when user interacts with a product in AI chat
  static Future<void> saveConversationId(String? conversationId) async {
    if (conversationId == null || conversationId.isEmpty || conversationId == 'new') return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_conversationKey, conversationId);
    } catch (_) {}
  }

  /// Get the stored conversationId
  static Future<String?> getConversationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_conversationKey);
    } catch (_) {
      return null;
    }
  }

  /// Clear the conversationId after checkout is completed
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_conversationKey);
    } catch (_) {}
  }
}
