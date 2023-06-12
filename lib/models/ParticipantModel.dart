import 'dart:core';

class ParticipantModel {
  int date;
  String pugId;
  String userId;
  String sex;

  // String username;

  ParticipantModel(
      {required this.date,
      required this.pugId,
      required this.sex,
      // required this.username,
      required this.userId});

  ParticipantModel.jsonData(
      {required this.date,
      required this.pugId,
      required this.sex,
      // required this.username,
      required this.userId});

  factory ParticipantModel.fromJsonData(Map<String, dynamic> json) {
    return ParticipantModel.jsonData(
      date: json['date'],
      sex: json['sex'] ?? "test",
      pugId: json['pugId'],
      // username: json['username'] ?? "test",
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pugId': pugId,
      'sex': sex,
      'date': date,
      // 'username': username,
    };
  }

  @override
  String toString() {
    return 'ParticipantModel{date: $date, pugId: $pugId, userId: $userId, sex: $sex}';
  }
}
