import 'dart:core';



class CommentModel{

  String id;
  String author;
  String content;
  String date ;

  CommentModel({ required this.id,  required this.author, required this.content, required this.date});


  CommentModel.jsonData({ required this.id,  required this.author, required this.content, required this.date});

  factory CommentModel.fromJsonData(Map<String,  dynamic> json){
    return CommentModel.jsonData(
      id: json['id'],
      author: json['author'],
      content: json['content'],
      date: json['date'],


    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id ,
      'author': author ,
      'content': content ,
      'date': date ,
    };
  }

}


