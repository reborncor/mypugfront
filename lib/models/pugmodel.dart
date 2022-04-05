import 'dart:core';

import 'package:mypug/models/pugdetailmodel.dart';




class PugModel{

  String id;
  String imageURL;
  String imageTitle;
  String imageDescription ;
  List<PugDetailModel> details;
  int like;

  PugModel({ required this.id,  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like});

  PugModel.jsonData({ required this.id,  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like});

  factory PugModel.fromJsonData(Map<String,  dynamic> json){
    return PugModel.jsonData(
      id: json['id'],
      imageURL: json['imageURL'],
      like: json['like'],
      imageDescription: json['imageDescription'],
      imageTitle: json['imageTitle'],
      details:  (json['details'] as List).map((e) => PugDetailModel.fromJsonData(e)).toList(),

    );
  }







}


