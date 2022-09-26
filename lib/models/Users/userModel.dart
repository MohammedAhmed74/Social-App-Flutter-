import 'package:flutter/material.dart';

class UserModel {
  late String email;
  late String name;
  late String phone;
  late String uId;
  late String bio;
  late String userImage;
  late String cover;

  UserModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    phone = json['phone'];
    name = json['name'];
    uId = json['uId'];
    bio = json['bio'];
    userImage = json['userImage'];
    cover = json['cover'];
  }

  UserModel({
    required this.email,
    required this.phone,
    required this.name,
    required this.uId,
    this.bio = 'this is my bio',
    this.userImage =
        'https://c.files.bbci.co.uk/10E5A/production/_105901296_male.jpg',
    this.cover = 'https://www.drodd.com/images14/white3.jpg',
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'uId': uId,
      'bio': bio,
      'userImage': userImage,
      'cover': cover,
    };
  }
}
