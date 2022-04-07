import 'dart:convert';
import 'dart:core';

import 'package:mypug/models/pugmodel.dart';

import 'BaseResponse.dart';


class ActualityResponse extends BasicResponse{


  late List<PugModel> pugs;


  ActualityResponse({ code,  message, payload}) : super(code: code, message:message, payload: payload);


  ActualityResponse.jsonData({ code,  message, payload, required this.pugs}) :super(code: code, message: message, payload: payload);

  factory ActualityResponse.fromJsonData(Map<String,  dynamic> json){

    return ActualityResponse.jsonData(
      code: json['code'],
      message: json['message'],
      pugs: (json['payload']['pugs'] as List).map((e) =>PugModel.fromJsonData(e)).toList(),


    );
  }
}


