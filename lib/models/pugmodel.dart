import 'dart:core';

import 'package:mypug/models/pugdetailmodel.dart';




class PugModel{

  String? id;
  String imageURL;
  String? imageTitle;
  String? imageDescription ;
  late List<PugDetailModel>? details;
  late int like;
  late String imageData;
  late int date;
  late bool isLiked;

  PugModel({ required this.id,  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like});

  PugModel.jsonData({  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like, required this.imageData, required this.date, required this.isLiked, required this.id});

  factory PugModel.fromJsonData(Map<String,  dynamic> json){
    return PugModel.jsonData(
      id : json['id'],
      date: json['date'],
      imageURL: json['imageURL'],
      imageData : json['imageData'],
      like: json['like'],
      imageDescription: json['imageDescription'],
      imageTitle: json['imageTitle'],
      isLiked: json['isLiked'],
      details:  (json['details'] as List).map((e) => PugDetailModel.fromJsonData(e)).toList(),

    );
  }







}


