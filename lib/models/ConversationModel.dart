import 'dart:core';

import 'package:mypug/models/userfactory.dart';

import 'MessageModel.dart';

class ConversationModel {
  String id;
  List<dynamic> members;
  List<UserFactory> membersInfos;

  List<MessageModel> chat;
  late List<dynamic> seen;

  ConversationModel({
    required this.id,
    required this.members,
    required this.chat,
    required this.membersInfos,
  });

  ConversationModel.jsonData(
      {required this.id,
      required this.members,
      required this.chat,
      required this.membersInfos,
      required this.seen});

  factory ConversationModel.fromJsonData(Map<String, dynamic> json) {
    return ConversationModel.jsonData(
      id: json['_id'],
      members: json['members'] as List,
      chat: (json['chat'] as List)
          .map((e) => MessageModel.fromJsonData(e))
          .toList(),
      membersInfos: (json['membersInfos'] as List)
          .map((e) => UserFactory.fromJsonData(e))
          .toList(),
      seen: json['seen'] as List,
    );
  }

  @override
  String toString() {
    return 'ConversationModel{id: $id, members: $members, chat: $chat, seen :$seen}';
  }
}
