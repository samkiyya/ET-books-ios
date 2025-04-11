class UserData {
  final int id;
  final String fname;
  final String lname;
  final String? email;
  final String? token;
  final String? password;
  final String? role;
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

  // Factory constructor to create an instance from a JSON map
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      fname: json['fname'] ?? "",
      lname: json['lname'] ?? "",
      email: json['email'],
      token: json['token'],
      password: json['password'],
      role: json['role'] ?? "",
      image: json['image'],
    );
  }

  // Method to convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fname': fname,
      'lname': lname,
      'email': email,
      'token': token,
      'password': password,
      'role': role,
      'image': image,
    };
  }
}

class LoginResponse {
  final String userToken;
  final UserData userData;

  LoginResponse({required this.userToken, required this.userData});

  // Factory constructor to create an instance from a JSON map
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userToken: json['userToken'] ?? "",
      userData: UserData.fromJson(json['userData']),
    );
  }

  // Method to convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'userData': userData.toJson(),
    };
  }
}
