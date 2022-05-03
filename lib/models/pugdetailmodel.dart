import 'dart:core';




class PugDetailModel{

  late int positionX;
  late int positionY;
  late String text;

  PugDetailModel({ required this.positionX,  required this.positionY,
    required this.text});


  PugDetailModel.jsonData({  required this.positionX,  required this.positionY,
    required this.text});

  factory PugDetailModel.fromJsonData(Map<String,  dynamic> json){
    return PugDetailModel.jsonData(
      text: json['text'] ,
      positionX: json['positionX'],
      positionY: json['positionY'],

    );
  }

  Map<String, dynamic> toJson() => {
    "text" : text,
    "positionX" : positionX,
    "positionY" : positionY,
    };







}


