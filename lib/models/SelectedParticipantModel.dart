import 'dart:core';

import 'package:mypug/models/ParticipantModel.dart';

class SelectedParticipant extends ParticipantModel {
  int vote;

  SelectedParticipant(
      {required this.vote, username, date, pugId, userId, sex, pugPicture})
      : super(
            username: username,
            date: date,
            pugId: pugId,
            sex: sex,
            pugPicture: pugPicture,
            userId: userId);

  SelectedParticipant.jsonData(
      {required this.vote, username, date, pugId, userId, sex, pugPicture})
      : super(
            username: username,
            date: date,
            pugId: pugId,
            sex: sex,
            pugPicture: pugPicture,
            userId: userId);

  factory SelectedParticipant.fromJsonData(Map<String, dynamic> json) {
    return SelectedParticipant.jsonData(
      username: json['username'],
      date: json['date'],
      sex: json['sex'],
      userId: json['userId'],
      pugPicture: json['pugPicture'],
      pugId: json['pugId'],
      vote: json['vote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pugId': pugId,
      'sex': sex,
      'date': date,
      'username': username,
      'vote': vote,
    };
  }

  @override
  String toString() {
    return 'SelectedParticipant{vote: $vote}';
  }
}
