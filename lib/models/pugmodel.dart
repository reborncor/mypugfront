import 'dart:core';

import 'package:mypug/models/CommentModel.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/userfactory.dart';

class PugModel {
  String id;
  String imageURL;
  String? imageTitle;
  late String imageDescription;

  late List<PugDetailModel>? details;
  late int like;
  late String? imageData;
  late int date;
  late bool isLiked;
  late UserFactory author;
  late List<CommentModel> comments;
  late bool isCrop;
  late int height;
  late int numberOfComments;

  PugModel(
      {required this.id,
      required this.imageURL,
      required this.imageTitle,
      required this.imageDescription,
      required this.details,
      required this.like});

  PugModel.jsonData(
      {required this.imageURL,
      required this.imageTitle,
      required this.imageDescription,
      required this.details,
      required this.like,
      required this.imageData,
      required this.date,
      required this.isLiked,
      required this.id,
      required this.author,
      required this.comments,
      required this.isCrop,
      required this.height,
      required this.numberOfComments});

  factory PugModel.fromJsonData(Map<String, dynamic> json) {
    return PugModel.jsonData(
      id: json['id'],
      date: json['date'],
      imageURL: json['imageURL'],
      imageData: json['imageData'],
      like: json['like'],
      imageDescription: json['imageDescription'],
      imageTitle: json['imageTitle'],
      isLiked: json['isLiked'],
      author: UserFactory.fromJsonData(json['author']),
      isCrop: json['isCrop'],
      height: json['height'],
      numberOfComments: json['numberOfComments'],
      details: (json['details'] as List)
          .map((e) => PugDetailModel.fromJsonData(e))
          .toList(),
      comments: (json['comments'] as List)
          .map((e) => CommentModel.fromJsonData(e))
          .toList(),
    );
  }



  @override
  String toString() {
    return 'PugModel{id: $id, imageURL: $imageURL, imageTitle: $imageTitle, imageDescription: $imageDescription, details: $details, like: $like, imageData: $imageData, date: $date, isLiked: $isLiked, author: $author, comments: $comments, isCrop: $isCrop}';
  }
}
