import 'dart:core';

import 'BaseResponse.dart';


class UserResponse extends BasicResponse{


  late String username;
  late String email;
  late String phoneNumber;
  late bool admin;
  late int followers;
  late int following;
  late int pugs;

  UserResponse({ code,  message, payload}) : super(code: code, message:message, payload: payload);


  UserResponse.jsonData({ code,  message, payload, required this.username, required this.phoneNumber, required this.admin,
    required this.followers, required this.following, required this.pugs}) :super(code: code, message: message, payload: payload);

  factory UserResponse.fromJsonData(Map<String,  dynamic> json){
    return UserResponse.jsonData(
      code: json['code'],
      message: json['message'],
      pugs: json['payload']['pugs'],
      username: json['payload']['username'],
      phoneNumber: json['payload']['phoneNumber'],
      admin: json['payload']['admin'],
      followers: json['payload']['followers'],
      following: json['payload']['following'],
    );
  }
}


