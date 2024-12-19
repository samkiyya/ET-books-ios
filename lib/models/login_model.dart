// models/login_response.dart
class UserData {
  final int id;
  final String fname;
  final String lname;
  final String? email;
  final String? token;
  final String? password;
  final String role;
  final String? image;

  UserData({
    required this.id,
    required this.fname,
    required this.lname,
    this.email,
    this.token,
    this.password,
    required this.role,
    this.image,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      fname: json['fname'] ?? "",
      lname: json['lname'] ?? "",
      email: json['email'] ?? "",
      token: json['token'],
      password: json['password'],
      role: json['role'] ?? "",
      image: json['image'],
    );
  }
}

class LoginResponse {
  final String userToken;
  final UserData userData;

  LoginResponse({required this.userToken, required this.userData});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userToken: json['userToken'] ?? "",
      userData: UserData.fromJson(json['userData']),
    );
  }
}
