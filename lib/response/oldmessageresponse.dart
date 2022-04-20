import 'dart:core';

import '../models/MessageModel.dart';
import 'BaseResponse.dart';




class OldMessageResponse extends BasicResponse{

  late List<MessageModel> oldmessages;

  OldMessageResponse({ code, message, payload}): super(code: code, message:message, payload: payload );

  OldMessageResponse.jsonData({required this.oldmessages, code, message, payload}) :super(code: code, message: message, payload: payload);

  factory OldMessageResponse.fromJsonData(Map<String,  dynamic> json){
    return OldMessageResponse.jsonData(
      code: json['code'],
      message: json['message'],
      oldmessages: (json['payload']['oldmessages'] as List).map((e) => MessageModel.fromJsonData(e)).toList(),
    );
  }



}


