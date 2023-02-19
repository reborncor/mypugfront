import 'dart:core';

class UserFactory {
  String username;
  String profilePicture;
  String id;

  UserFactory({
    required this.username,
    required this.profilePicture,
    required this.id,
  });

  UserFactory.jsonData({
    required this.username,
    required this.profilePicture,
    required this.id,
  });

  factory UserFactory.fromJsonData(Map<String, dynamic> json) {
    return UserFactory.jsonData(
      username: json['username'],
      profilePicture: json['profilePicture'],
      id: json['_id'],

    );
  }
}
