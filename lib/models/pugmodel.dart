import 'dart:core';

import 'package:mypug/models/CommentModel.dart';
import 'package:mypug/models/MessageModel.dart';
import 'package:mypug/models/pugdetailmodel.dart';




class PugModel{

  String id;
  String imageURL;
  String? imageTitle;
  String? imageDescription ;
  late List<PugDetailModel>? details;
  late int like;
  late String? imageData;
  late int date;
  late bool isLiked;
  late String author;
  late List<CommentModel> comments;

  PugModel({ required this.id,  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like});

  PugModel.jsonData({  required this.imageURL,  required this.imageTitle,required this.imageDescription,
    required this.details,required this.like, required this.imageData, required this.date, required this.isLiked, required this.id, required this.author, required this.comments});

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
      author: json['author'],
      details:  (json['details'] as List).map((e) => PugDetailModel.fromJsonData(e)).toList(),
      comments:  (json['comments'] as List).map((e) => CommentModel.fromJsonData(e)).toList(),

    );
  }







}


