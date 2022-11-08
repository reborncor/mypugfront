import 'dart:core';

import '../models/ConversationModel.dart';
import 'BaseResponse.dart';



class ConversationResponse extends BasicResponse{

  late ConversationModel conversation;

  ConversationResponse({code, message, payload}): super(code: code, message:message, payload: payload );

  ConversationResponse.jsonData({required this.conversation, code, message, payload}) :super(code: code, message: message, payload : payload);

  factory ConversationResponse.fromJsonData(Map<String,  dynamic> json){
    return ConversationResponse.jsonData(
      code: json['code'],
      message: json['message'],
      conversation: ConversationModel.fromJsonData( json['payload']),
    );
  }



}


