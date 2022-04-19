import 'dart:core';

import 'MessageModel.dart';



class ConversationModel{

  String id;
  List<dynamic> members;
  List<MessageModel> chat;

  ConversationModel({ required this.id,  required this.members, required this.chat});


  ConversationModel.jsonData({required this.id,  required this.members, required this.chat});

  factory ConversationModel.fromJsonData(Map<String,  dynamic> json){
    return ConversationModel.jsonData(
      id: json['_id'],
      members: json['members'] as List,
      chat:  (json['chat'] as List).map((e) => MessageModel.fromJsonData(e)).toList(),


    );
  }

}


