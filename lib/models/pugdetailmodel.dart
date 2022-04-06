import 'dart:core';




class PugDetailModel{

  late String? id;
  late double? positionX;
  late double? positionY;
  late String? text;

  PugDetailModel({ required this.id,  required this.positionX,  required this.positionY,
    required this.text});


  PugDetailModel.jsonData({ required this.id,  required this.positionX,  required this.positionY,
    required this.text});

  factory PugDetailModel.fromJsonData(Map<String,  dynamic> json){
    return PugDetailModel.jsonData(
      id: json['id'],
      text: json['text'] ,
      positionX: json['positionX'],
      positionY: json['positionY'],


    );
  }







}


