import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Manages authentication state with real API calls.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({AuthRepository? repository})
    : _repository = repository ?? AuthRepository(),
      super(const AuthState());

  final AuthRepository _repository;

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
  void logout() {
    ApiClient.instance.clearAuthToken();
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
