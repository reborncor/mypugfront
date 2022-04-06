import 'dart:core';

import 'package:mypug/models/pugdetailmodel.dart';




class PugModel{

  String? id;
  String imageURL;
  String? imageTitle;
  String? imageDescription ;
  late List<PugDetailModel>? details;
  int like;
  late String imageData;
  late int date;

  PugModel({ required this.id,  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like});

  PugModel.jsonData({  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like, required this.imageData, required this.date});

  factory PugModel.fromJsonData(Map<String,  dynamic> json){
    return PugModel.jsonData(
      date: json['date'],
      imageURL: json['imageURL'],
      imageData : json['imageData'],
      like: json['like'],
      imageDescription: json['imageDescription'],
      imageTitle: json['imageTitle'],
      details:  (json['details'] as List).map((e) => PugDetailModel.fromJsonData(e)).toList(),

    );
  }







}


