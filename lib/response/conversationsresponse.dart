
import 'dart:core';

import '../models/ConversationModel.dart';
import 'BaseResponse.dart';



class ConversationsResponse extends BasicResponse{

  late List<ConversationModel> conversations;

  ConversationsResponse({code, message, payload}): super(code: code, message:message,payload: payload );

  ConversationsResponse.jsonData({required this.conversations, code,  message, payload}) :super(code: code, message: message, payload: payload);

  factory ConversationsResponse.fromJsonData(Map<String,  dynamic> json){
    return ConversationsResponse.jsonData(
      code: json['code'],
      message: json['message'],
      conversations:  (json['payload']['conversations'] as List).map((e) => ConversationModel.fromJsonData(e)).toList(),
    );
  }



}


