import 'dart:convert';

const sex = ['Female', 'Male'];

class User {
  final String id;
  final String fullName;
  final DateTime? birthDay;
  final String sex;
  final String email;
  final String password;
  final String image;
  final String phoneNumber;
  final String token;

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "fullName": this.fullName,
      "birthDay": birthDay != null ? birthDay!.toIso8601String() : null,
      "sex": this.sex,
      "email": this.email,
      "password": this.password,
      "image": this.image,
      "phoneNumber": this.phoneNumber,
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json["_id"] ?? "",
      fullName: json["fullName"] ?? "",
      birthDay: json["birthDay"] != null ? DateTime.parse(json["birthDay"]) : null,
      sex: json["sex"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      image: json["image"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      token: '',
    );
  }

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  factory User.newUser() {
    return User(
      id: '',
      fullName: '',
      birthDay: null,
      sex: '',
      email: '',
      password: '',
      image: '',
      phoneNumber: '',
      token: '',
    );
  }

  User({
    required this.id,
    required this.fullName,
    required this.birthDay,
    required this.sex,
    required this.email,
    required this.password,
    required this.image,
    required this.phoneNumber,
    required this.token,
  });

  String? fullNameValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter full name';
    }
    return null;
  }

  String? birthDayValidate(DateTime? value) {
    if (value == null) {
      return 'Please choose birthday';
    }
    return null;
  }

  String? sexValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please choose sex';
    }
    return null;
  }

  String? emailValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '"Email" cannot be blank !';
    }
    // Biểu thức chính quy để kiểm tra định dạng email
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!emailRegex.hasMatch(value.trim())) {
      return '"EMAIL" must be a valid email !';
    }
    return null;
  }

  String? passwordValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '"Password" cannot be blank !';
    }
    if (value.trim().length < 6) {
      return '"Password" must be at least 6 characters!';
    }
    return null;
  }
}
