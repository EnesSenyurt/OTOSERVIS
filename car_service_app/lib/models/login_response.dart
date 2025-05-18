class LoginResponse {
  final String token;
  final String role;
  LoginResponse({required this.token, required this.role});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      role: json['role'] as String,
    );
  }
}
