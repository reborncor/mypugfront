import 'dart:core';

class PugDetailModel {
  late double positionX;
  late double positionY;
  late String text;

  PugDetailModel(
      {required this.positionX, required this.positionY, required this.text});

  PugDetailModel.jsonData(
      {required this.positionX, required this.positionY, required this.text});

  factory PugDetailModel.fromJsonData(Map<String, dynamic> json) {
    return PugDetailModel.jsonData(
      text: json['text'],
      positionX: double.parse(json['positionX'].toString()),
      positionY: double.parse(json['positionY'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        "text": text,
        "positionX": positionX,
        "positionY": positionY,
      };

}
