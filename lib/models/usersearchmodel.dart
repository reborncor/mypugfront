import 'dart:core';

class UserSearchModel {
  String username;

  UserSearchModel({required this.username});

  UserSearchModel.jsonData({
    required this.username,
  });

  factory UserSearchModel.fromJsonData(Map<String, dynamic> json) {
    return UserSearchModel.jsonData(
      username: json['username'],
    );
  }
}
