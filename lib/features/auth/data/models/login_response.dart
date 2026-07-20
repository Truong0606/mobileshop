/// Response from `POST /api/v1/auth/login`.
///
/// The server returns an access token (and optionally user info)
/// when credentials are valid.
class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final String? userId;
  final String? email;
  final String? fullName;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    this.userId,
    this.email,
    this.fullName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Support multiple response formats the server might use
    return LoginResponse(
      accessToken:
          json['accessToken'] as String? ??
          json['access_token'] as String? ??
          json['token'] as String? ??
          '',
      refreshToken:
          json['refreshToken'] as String? ?? json['refresh_token'] as String?,
      userId: json['userId'] as String? ?? json['user_id'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String? ?? json['full_name'] as String?,
    );
  }
}
