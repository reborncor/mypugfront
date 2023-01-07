import 'dart:core';

class BasicResponse<T> {
  int code;
  String message;
  T payload;

  BasicResponse(
      {required this.code, required this.message, required this.payload});

  BasicResponse.jsonData(
      {required this.code, required this.message, required this.payload});

  factory BasicResponse.fromJsonData(Map<String, dynamic> json) {
    return BasicResponse.jsonData(
      code: json['code'],
      message: json['message'],
      payload: (json['payload']),
    );
  }
}
