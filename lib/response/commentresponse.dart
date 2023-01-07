import 'dart:core';

import '../models/CommentModel.dart';
import 'BaseResponse.dart';

class CommentResponse extends BasicResponse {
  late List<CommentModel> comments;

  CommentResponse({code, message, payload})
      : super(code: code, message: message, payload: payload);

  CommentResponse.jsonData({code, message, payload, required this.comments})
      : super(code: code, message: message, payload: payload);

  factory CommentResponse.fromJsonData(Map<String, dynamic> json) {
    return CommentResponse.jsonData(
        code: json['code'],
        message: json['message'],
        comments: (json['payload'] as List)
            .map((e) => CommentModel.fromJsonData(e))
            .toList());
  }
}
