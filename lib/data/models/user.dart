class User {
  final int id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  String? imageProfile;
  String? role;
  final String? status;
  final String? completionStatus;
  final String? statusLabel;

  User({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.imageProfile,
    this.role,
    this.status,
    this.completionStatus,
    this.statusLabel,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        userName: json['user_name'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        phoneNumber: json['phone_number'],
        dateOfBirth: json['date_of_birth'],
        gender: json['gender'],
        address: json['address'],
        imageProfile: json['image_profile'],
        role: json['role'],
        status: json['status'],
        completionStatus: json['completionStatus'],
        statusLabel: json['statusLabel']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address': address,
      'image_profile': imageProfile,
      'role': role,
      'status': status,
      'completionStatus': completionStatus,
      'statusLabel': statusLabel
    };
  }
}
