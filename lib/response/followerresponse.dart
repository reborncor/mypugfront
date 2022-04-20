import 'dart:core';

import 'package:mypug/models/usersearchmodel.dart';

import 'BaseResponse.dart';


class FollowerResponse extends BasicResponse{


  late List<UserSearchModel> usernames;


  FollowerResponse({ code,  message, payload}) : super(code: code, message:message, payload: payload);


  FollowerResponse.jsonData({ code,  message, payload, required this.usernames}) :super(code: code, message: message, payload: payload);

  factory FollowerResponse.fromJsonData(Map<String,  dynamic> json){
    return FollowerResponse.jsonData(
        code: json['code'],
        message: json['message'],
        usernames:  (json['payload'] as List).map((e) => UserSearchModel.fromJsonData(e)).toList()
    );
  }
}


