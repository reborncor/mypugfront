import 'dart:core';

class BasicResponse<T> {
  int code;
  String message;
  T payload;

  BasicResponse(
      {required this.code, required this.message, required this.payload});

  BasicResponse.jsonData(
      {required this.code, required this.message, required this.payload});

  factory BasicResponse.fromJsonData(
      Map<String, dynamic> json, [T Function(Map<String, dynamic>)? fromJson]) {
    return BasicResponse.jsonData(
      code: json['code'],
      message: json['message'],
      payload: fromJson != null
          ? fromJson(json['payload'])
          : json['payload'],
    );
  }
}
