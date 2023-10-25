import 'dart:core';

class UserSearchModel {
  String username;
  String profilePicture;

  UserSearchModel({
    required this.username,
    required this.profilePicture,
  });

  UserSearchModel.jsonData({
    required this.username,
    required this.profilePicture,
  });

  factory UserSearchModel.fromJsonData(Map<String, dynamic> json) {
    return UserSearchModel.jsonData(
      username: json['username'],
      profilePicture: json['profilePicture'],
    );
  }
}
