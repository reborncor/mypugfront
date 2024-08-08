import 'dart:core';

import 'package:mypug/models/CompetitionModel.dart';

import 'BaseResponse.dart';

class CompetitionReponse extends BasicResponse {
  late CompetitionModel competition;

  CompetitionReponse({code, message, payload})
      : super(code: code, message: message, payload: payload);

  CompetitionReponse.jsonData(
      {code, message, payload, required this.competition})
      : super(code: code, message: message, payload: payload);

  factory CompetitionReponse.fromJsonData(Map<String, dynamic> json) {
    return CompetitionReponse.jsonData(
        code: json['code'],
        message: json['message'],
        competition: CompetitionModel.fromJsonData(json['payload']));
  }

  @override
  String toString() {
    return 'CompetitionReponse{competition: $competition}';
  }
}
