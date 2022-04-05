import 'dart:core';




class UserModel{

  String id;
  String username;
  String password;
  String email ;
  bool admin;
  String phoneNumber;
  int following = 0 ;
  int followers = 0;

  UserModel({ required this.id,  required this.username,  required this.password,
    required this.email,required this.admin, required this.phoneNumber});







}


