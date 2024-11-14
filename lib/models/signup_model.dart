// lib/models/signup_model.dart

class SignupModel {
  final String email;
  final String password;
  final String fname;
  final String lname;
  final String phone;
  final String city;
  final String country;
  final String role;
  final String bio;
  final String image;

  SignupModel({
    required this.email,
    required this.password,
    required this.fname,
    required this.lname,
    required this.phone,
    required this.city,
    required this.country,
    required this.role,
    required this.bio,
    required this.image,
  });

  // Convert to JSON format
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fname': fname,
      'lname': lname,
      'phone': phone,
      'city': city,
      'country': country,
      'role': role,
      'bio': bio,
      'image': image,
    };
  }
}
