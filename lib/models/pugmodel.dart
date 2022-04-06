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

  PugModel({ required this.id,  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like});

  PugModel.jsonData({  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like, required this.imageData});

  factory PugModel.fromJsonData(Map<String,  dynamic> json){
    return PugModel.jsonData(
      imageURL: json['imageURL'],
      imageData : json['imageData'],
      like: json['like'],
      imageDescription: json['imageDescription'],
      imageTitle: json['imageTitle'],
      details:  (json['details'] as List).map((e) => PugDetailModel.fromJsonData(e)).toList(),

    );
  }







}


