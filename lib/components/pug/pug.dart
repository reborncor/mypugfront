
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/models/pugmodel.dart';

import '../design/design.dart';


class Pug extends StatefulWidget {

  final routeName = '/pug';
  final PugModel? model;


  const Pug({Key? key, this.model}) : super(key: key);

  const Pug.withPugModel({Key? key, required this.model }) : super(key: key);

  @override
  PugState createState() => PugState();
}

class PugState extends State<Pug> {



  late String imageURL;
  late String imageTitle;
  late String imageDescription;
  late int imageLike;
  List<Offset> points = [];

  bool isExpanded = false;
  bool isVisible = false;
  @override
  void initState() {

    super.initState();
    imageURL = widget.model!.imageURL;
    imageTitle = widget.model!.imageTitle!;
    imageDescription = widget.model!.imageDescription!;
    imageLike = widget.model!.like;
    points.clear();
    for (var element in widget.model!.details!) {points.add(Offset(element.positionX.toDouble(),element.positionY.toDouble()));};
     }





  Widget imageContent(String imageUrl ){
    return GestureDetector(
      child: Container(
      child:
        Container(
          height: 300,
          child: Visibility(
            visible: isVisible,
            child: Stack(
              children: [
                Stack(
                    children: points.asMap().map((i,e) => MapEntry(i,
                      Positioned(child: Column(children: [Image( image : AssetImage('asset/images/r-logo.png',), width: 40, height: 40, color: APPCOLOR,), Text((widget.model!.details![i].text) , style: TextStyle(fontSize: 15, color: Colors.white),)],)
                 , left: e.dx, top: e.dy, ),)).values.toList()
                )],),) ,
        ),
      height: 300,
      decoration: BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(base64Decode(widget.model!.imageData)),
            fit: BoxFit.contain,
          )
      ),
    ),onTap: () {
      setState(() {
        isVisible = !isVisible;
      });
    },);

  }
  Widget imageInformation(String title,int like){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text(title),
        Row(
            children: [
              TextButton.icon(onPressed: () {
              }, icon: const Icon(Icons.favorite), label: Text(like.toString(), style: const TextStyle(color: Colors.black),),),

              IconButton(onPressed: () {
              }, icon: const Icon(Icons.share)),
            ],
        )
       
      ],) ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        backgroundColor: Colors.white,

        body:  Column(
          children: [
            SizedBox( width: 500, height : 500,child :imageContent(imageURL)),
            imageInformation(imageTitle,imageLike),

          ],
        )

    );
  }
}

class OpenPainter extends CustomPainter {


  final List<Offset> points ;
  OpenPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round //rounded points
      ..strokeWidth = 10;
    //list of points
    var points = this.points;
    //draw points on canvas
    canvas.drawPoints(PointMode.points, points, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}