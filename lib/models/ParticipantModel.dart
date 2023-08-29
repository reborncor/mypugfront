import 'dart:core';

class ParticipantModel {
  int date;
  String pugId;
  String userId;
  String sex;
  String pugPicture;
  String username;

  // String username;

  ParticipantModel(
      {required this.date,
      required this.pugId,
      required this.sex,
      required this.pugPicture,
      required this.username,
      required this.userId});

  ParticipantModel.jsonData(
      {required this.date,
      required this.pugId,
      required this.sex,
      required this.username,
      required this.pugPicture,

      // required this.username,
      required this.userId});

  factory ParticipantModel.fromJsonData(Map<String, dynamic> json) {
    return ParticipantModel.jsonData(
      date: json['date'] ?? 0,
      sex: json['sex'] ?? "",
      pugId: json['pugId'] ?? "",
      pugPicture: json['pugPicture'] ?? "",
      username: json['username'] ?? "",
      userId: json['userId'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pugId': pugId,
      'sex': sex,
      'date': date,
      'pugPicture': pugPicture,
      // 'username': username,
    };
  }

  @override
  String toString() {
    return 'ParticipantModel{date: $date, pugId: $pugId, userId: $userId, sex: $sex, pugPicture :$pugPicture}';
  }
}
