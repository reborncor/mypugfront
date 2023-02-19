import 'dart:core';

import 'package:mypug/models/pugmodel.dart';

class MessageModel {
  String id;
  String senderUsername;
  String receiverUsername;
  dynamic content;
  String time;

  MessageModel(
      {required this.id,
      required this.senderUsername,
      required this.receiverUsername,
      required this.content,
      required this.time});

  MessageModel.jsonData(
      {required this.id,
      required this.senderUsername,
      required this.receiverUsername,
      required this.content,
      required this.time});

  factory MessageModel.fromJsonData(Map<String, dynamic> json) {
    return MessageModel.jsonData(
      id: json['id'],
      senderUsername: json['senderUsername'],
      receiverUsername: json['receiverUsername'],
      content: json['content'] is String ? json['content'] : PugModel.fromJsonData(json['content']) ,
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
      'content': content.toString(),
      'time': time,
    };
  }

  @override
  String toString() {
    return 'MessageModel{id: $id, senderUsername: $senderUsername, receiverUsername: $receiverUsername, content: $content, time: $time}';
  }
}
