import 'dart:core';

import 'package:mypug/models/pugmodel.dart';

class MessageModel {
  String id;
  String senderUsername;
  String receiverUsername;
  dynamic content;
  String type;

  String time;

  MessageModel({required this.id,
    required this.senderUsername,
    required this.receiverUsername,
    required this.content,
    required this.time,
    required this.type});

  MessageModel.jsonData({required this.id,
    required this.senderUsername,
    required this.receiverUsername,
    required this.content,
    required this.type,
    required this.time});

  factory MessageModel.fromJsonData(Map<String, dynamic> json) {
    return MessageModel.jsonData(
      id: json['id'],
      senderUsername: json['senderUsername'],
      receiverUsername: json['receiverUsername'],
      content: json['type'] == "text" ? json['content'] : PugModel
          .fromJsonData(json['content']),
      time: json['time'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
      'content': content,
      'time': time,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'MessageModel{id: $id, senderUsername: $senderUsername, receiverUsername: $receiverUsername, content: $content, time: $time, tyype: $type,}';
  }
}
