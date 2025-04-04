class SignupModel {
  final String id;
  final String email;
  final String fname;
  final String lname;
  final String? phone;
  final String? city;
  final String? country;
  final String? role;
  final String? bio;
  final String? image;
  final bool is2FAEnabled;
  final bool isVerified;

  SignupModel({
    required this.id,
    required this.email,
    required this.fname,
    required this.lname,
    this.phone,
    this.city,
    this.country,
    this.role,
    this.bio,
    this.image,
    this.is2FAEnabled = false,
    this.isVerified = false,
  });

  // Convert to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fname': fname,
      'lname': lname,
      'phone': phone,
      'city': city,
      'country': country,
      'role': role,
      'bio': bio,
      'image': image,
      'isTwoStepOn': is2FAEnabled,
      'isVerified': isVerified,
    };
  }

  // Convert from JSON format
  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      id: json['id'],
      email: json['email'] ?? "",
      fname: json['fname'] ?? "",
      lname: json['lname'] ?? "",
      phone: json['phone'] ?? '',
      city: json['city'] ?? "",
      country: json['country'] ?? '',
      role: json['role'] ?? '',
      bio: json['bio'] ?? '',
      image: json['image'] ?? '',
      is2FAEnabled: json['isTwoStepOn'] ?? false,
      isVerified: json['isVerified'] ?? false,
    );
  }
}
