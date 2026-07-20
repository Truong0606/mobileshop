import 'package:smart_shopping_chatbot/core/network/api_client.dart';
import 'package:smart_shopping_chatbot/features/auth/data/models/login_request.dart';
import 'package:smart_shopping_chatbot/features/auth/data/models/login_response.dart';
import 'package:smart_shopping_chatbot/features/auth/data/models/register_request.dart';
import 'package:smart_shopping_chatbot/features/auth/data/models/register_response.dart';

/// Repository that handles authentication API calls.
///
/// Endpoints:
/// - `POST /auth/login`    → [LoginResponse]
/// - `POST /auth/register` → [RegisterResponse]
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  /// Authenticate user with email and password.
  ///
  /// Calls `POST /auth/login` and returns a [LoginResponse] containing
  /// the access token.
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );

    return LoginResponse.fromJson(response.data!);
  }

  /// Register a new user account.
  ///
  /// Calls `POST /auth/register` with email, password, and fullName.
  /// Returns a [RegisterResponse] with the server's confirmation.
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
    );

    return RegisterResponse.fromJson(response.data!);
  }
}
