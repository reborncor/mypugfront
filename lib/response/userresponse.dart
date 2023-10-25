import 'dart:core';

import 'BaseResponse.dart';


class UserResponse extends BasicResponse{


  late String username;
  late String email;
  late String phoneNumber;
  late String profilePicture;
  late bool admin;
  late int followers;
  late int following;
  late int pugs;
  late bool? isFollowing;
  late String? description;

  UserResponse({ code,  message, payload}) : super(code: code, message:message, payload: payload);


  UserResponse.jsonData({ code,  message, payload, required this.username,  required this.email, required this.phoneNumber, required this.admin,
    required this.followers, required this.following, required this.pugs, required this.isFollowing, required this.profilePicture, required this.description,}) :super(code: code, message: message, payload: payload);


  factory UserResponse.fromJsonData(Map<String,  dynamic> json){
    return UserResponse.jsonData(
      code: json['code'],
      message: json['message'],
      pugs: json['payload']['pugs'],
      username: json['payload']['username'],
      email: json['payload']['email'],
      phoneNumber: json['payload']['phoneNumber'],
      admin: json['payload']['admin'],
      followers: json['payload']['followers'],
      following: json['payload']['following'],
      isFollowing: json['payload']['isFollowing'],
      profilePicture: json['payload']['profilePicture'],
      description: json['payload']['description'],

    );
  }
  @override
  String toString() {
    return 'UserResponse{username: $username, email: $email, phoneNumber: $phoneNumber, profilePicture: $profilePicture, admin: $admin, followers: $followers, following: $following, pugs: $pugs, isFollowing: $isFollowing, description: $description}';
  }

}


