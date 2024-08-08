import 'dart:core';

class UserFactory {
  String username = "";
  String profilePicture = "";
  String id = "";

  UserFactory({
    required this.username,
    required this.profilePicture,
    required this.id,
  });

  UserFactory.NullValue();

  UserFactory.jsonData({
    required this.username,
    required this.profilePicture,
    required this.id,
  });

  @override
  String toString() {
    return 'UserFactory{username: $username, profilePicture: $profilePicture, id: $id}';
  }


  factory UserFactory.fromJsonData(Map<String, dynamic> json) {
    return UserFactory.jsonData(
      username: json['username'],
      profilePicture: json['profilePicture'] ?? "",
      id: json['_id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'profilePicture': profilePicture,
    '_id': id,
  };

}
