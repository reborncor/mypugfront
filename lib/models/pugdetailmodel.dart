import 'dart:core';




class PugDetailModel{

  String id;
  double positionX;
  double positionY;
  String text;

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


