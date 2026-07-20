/// Response from `POST /api/v1/auth/register`.
///
/// The server confirms registration success and optionally returns user info.
class RegisterResponse {
  final String? message;
  final String? userId;
  final String? email;
  final String? fullName;

  const RegisterResponse({
    this.message,
    this.userId,
    this.email,
    this.fullName,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String?,
      userId: json['userId'] as String? ?? json['user_id'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String? ?? json['full_name'] as String?,
    );
  }
}
