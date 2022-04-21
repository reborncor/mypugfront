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
  late int pugs;

  SignInResponse({ code,  message, payload}) : super(code: code, message:message, payload: payload);


  SignInResponse.jsonData({ code,  message, payload, required this.username, required this.phoneNumber, required this.admin,
    required this.followers, required this.following, required this.pugs,required this.token,required this.email}) :super(code: code, message: message, payload: payload);

  factory SignInResponse.fromJsonData(Map<String,  dynamic> json){
    return SignInResponse.jsonData(
      code: json['code'],
      message: json['message'],
      pugs: json['payload']['pugs'],
      username: json['payload']['username'],
      phoneNumber: json['payload']['phoneNumber'],
      admin: json['payload']['admin'],
      email: json['payload']['email'],

      followers: json['payload']['followers'],
      following: json['payload']['following'],
      token: json['token'],

    );
  }
}


