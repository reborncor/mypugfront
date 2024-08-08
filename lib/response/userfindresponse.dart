import 'dart:core';

import 'package:mypug/models/usersearchmodel.dart';

import 'BaseResponse.dart';


class UserFindResponse extends BasicResponse{


  late List<UserSearchModel> users;


  UserFindResponse({ code,  message, payload}) : super(code: code, message:message, payload: payload);


  UserFindResponse.jsonData({ code,  message, payload, required this.users}) :super(code: code, message: message, payload: payload);

  factory UserFindResponse.fromJsonData(Map<String,  dynamic> json){
    return UserFindResponse.jsonData(
      code: json['code'],
      message: json['message'],
        users:  (json['payload'] as List).map((e) => UserSearchModel.fromJsonData(e)).toList()
    );
  }
}


