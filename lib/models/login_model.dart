// models/login_response.dart
class UserData {
  final int id;
  final String fname;
  final String lname;
  final String role;
  final String image;

  UserData({required this.id, required this.fname, required this.lname, required this.role, required this.image});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?? 0,
      fname: json['fname']??"",
      lname: json['lname']??"",
      role: json['role']??"",
      image: json['image']??"",
    );
  }
}

class LoginResponse {
  final String userToken;
  final UserData userData;

  LoginResponse({required this.userToken, required this.userData});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userToken: json['userToken'],
      userData: UserData.fromJson(json['userData']),
    );
  }
}
