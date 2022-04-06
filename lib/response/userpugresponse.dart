import 'dart:convert';
import 'dart:core';

import 'package:mypug/models/pugmodel.dart';

import 'BaseResponse.dart';


class UserPugResponse extends BasicResponse{


  late String username;
  late List<PugModel> pugs;


  UserPugResponse({ code,  message, payload}) : super(code: code, message:message, payload: payload);


  UserPugResponse.jsonData({ code,  message, payload, required this.username, required this.pugs}) :super(code: code, message: message, payload: payload);

  factory UserPugResponse.fromJsonData(Map<String,  dynamic> json){

    return UserPugResponse.jsonData(
      code: json['code'],
      message: json['message'],
      username: json['payload']['username'],
      pugs: (json['payload']['pugs'] as List).map((e) =>PugModel.fromJsonData(e)).toList(),


    );
  }
}


