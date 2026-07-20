import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:smart_shopping_chatbot/core/network/api_client.dart';
import 'package:smart_shopping_chatbot/core/network/api_exceptions.dart';
import 'package:smart_shopping_chatbot/features/auth/data/models/login_request.dart';
import 'package:smart_shopping_chatbot/features/auth/data/models/register_request.dart';
import 'package:smart_shopping_chatbot/features/auth/data/repositories/auth_repository.dart';
import 'package:smart_shopping_chatbot/features/auth/domain/entities/user.dart';

/// Authentication state – either authenticated with a [User] or not.
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final String? token;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.token,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    String? token,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      token: clearUser ? null : (token ?? this.token),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({AuthRepository? repository, FlutterSecureStorage? storage})
    : _repository = repository ?? AuthRepository(),
      _storage = storage ?? const FlutterSecureStorage(),
      super(const AuthState()) {
    _loadToken();
  }

  final AuthRepository _repository;
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'auth_email';

  Future<void> _loadToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final email = await _storage.read(key: _emailKey);
      if (token != null && token.isNotEmpty) {
        ApiClient.instance.setAuthToken(token);
        final user = User(
          id: 'user_restored',
          name: _nameFromEmail(email ?? 'User'),
          email: email ?? '',
          avatarUrl: null,
          createdAt: DateTime.now(),
        );
        state = AuthState(user: user, token: token);
      }
    } catch (e) {
      // Ignore secure storage read errors
    }
  }

  /// Login via `POST /api/v1/auth/login`.
  ///
  /// On success: stores the access token in [ApiClient] and creates
  /// a [User] from the response data.
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.login(
        LoginRequest(email: email, password: password),
      );

      // Store the token for subsequent authenticated requests
      ApiClient.instance.setAuthToken(response.accessToken);

      await _storage.write(key: _tokenKey, value: response.accessToken);
      await _storage.write(key: _emailKey, value: response.email ?? email);

      // Build user from response or from the email
      final user = User(
        id: response.userId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: response.fullName ?? _nameFromEmail(email),
        email: response.email ?? email,
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      state = AuthState(user: user, token: response.accessToken);
      return true;
    } on ApiException catch (e) {
      state = AuthState(errorMessage: e.message);
      return false;
    } catch (e) {
      state = AuthState(errorMessage: 'Đã xảy ra lỗi: ${e.toString()}');
      return false;
    }
  }

  /// Register via `POST /api/v1/auth/register`.
  ///
  /// On success: shows a success state. The user can then log in
  /// with their new credentials.
  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.register(
        RegisterRequest(email: email, password: password, fullName: name),
      );

      // After successful registration, automatically log in
      return await login(email, password);
    } on ApiException catch (e) {
      state = AuthState(errorMessage: e.message);
      return false;
    } catch (e) {
      state = AuthState(errorMessage: 'Đã xảy ra lỗi: ${e.toString()}');
      return false;
    }
  }

  /// Log out and clear all auth data.
  Future<void> logout() async {
    ApiClient.instance.clearAuthToken();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
    state = const AuthState();
  }

  /// Clear any error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Extract a display name from email (e.g., "john.doe@gmail.com" → "John Doe").
  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    return local
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

/// Global auth provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
