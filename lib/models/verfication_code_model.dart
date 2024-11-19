class VerificationCode {
  final String code;
  final String email;
  final DateTime expiresAt;

  VerificationCode(
      {required this.code, required this.email, required this.expiresAt});

  factory VerificationCode.fromJson(Map<String, dynamic> json) {
    return VerificationCode(
      code: json['code'],
      email: json['email'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}
