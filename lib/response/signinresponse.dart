import 'dart:core';

import 'BaseResponse.dart';


class SignInResponse extends BasicResponse{


  late String token;
  late String username;
  late String email;
  late String phoneNumber;
  late bool admin;
  late int followers;
  late int following;

  SignInResponse({ code,  message, payload}) : super(code: code, message:message, payload: payload);


  SignInResponse.jsonData({ code,  message, payload, required this.username, required this.phoneNumber, required this.admin,
    required this.followers, required this.following, required this.token}) :super(code: code, message: message, payload: payload);

  factory SignInResponse.fromJsonData(Map<String,  dynamic> json){
    return SignInResponse.jsonData(
      code: json['code'],
      message: json['message'],
      username: json['payload']['username'],
      phoneNumber: json['payload']['phoneNumber'],
      admin: json['payload']['admin'],
      followers: json['payload']['followers'],
      following: json['payload']['following'],
      token: json['token'],
    );
  }
}


