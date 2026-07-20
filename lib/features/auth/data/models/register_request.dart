/// Request body for `POST /api/v1/auth/register`.
class RegisterRequest {
  final String email;
  final String password;
  final String fullName;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'fullName': fullName,
  };
}
