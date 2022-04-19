
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/api.dart';
import 'package:mypug/models/pugmodel.dart';

import '../../models/CommentModel.dart';


class PugItem extends StatefulWidget {

  final routeName = '/pugitem';
  final PugModel model;


  const PugItem({Key? key, required this.model}) : super(key: key);
  @override
  PugItemState createState() => PugItemState();
}

class PugItemState extends State<PugItem> {

  late String imageURL;
  late String imageTitle;
  late String imageDescription;
  late int imageLike;
  late List<Offset>points = [];

  bool isExpanded = false;
  bool isVisible = false;
  @override
  void initState() {

    super.initState();
    imageURL = widget.model.imageURL;
    imageTitle = widget.model.imageTitle!;
    imageDescription = widget.model.imageDescription!;
    imageLike = widget.model.like;
    points.clear();
    for (var element in widget.model.details!) {
      points.add(Offset(element.positionX!.toDouble(), element.positionY!.toDouble()));
    }

  }





  Widget imageContent(){
    return GestureDetector(
      child: Container(
        child:
        Visibility(
          visible: isVisible,
          child: Stack(
            children: [
              CustomPaint(painter: OpenPainter(points: points)),
              Stack(children: points.asMap().map((i,e) => MapEntry(i, Positioned(child: Text((widget.model.details![i].text ?? "") , style: TextStyle(fontSize: 15, color: Colors.white),), left: e.dx, top: e.dy, ),)).values.toList()
              )],),),
        height: 300,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(base64Decode(widget.model.imageData)),
              fit: BoxFit.fitWidth,
            )
        ),
      ),onTap: () {
      isVisible = !isVisible;
      setState(() {

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
              TextButton.icon(onPressed: () async {
                var result = await likePug("test","test");
              }, icon: const Icon(Icons.favorite), label: Text(like.toString(), style: const TextStyle(color: Colors.black),),),

              IconButton(onPressed: () {
              }, icon: const Icon(Icons.share)),
            ],
          )

        ],) ,
    );
  }

  Widget imageCommentaire(List<CommentModel> list){
    return Text(list.isEmpty ? "test": list.first.content);
  }

  Widget imageDetail(String detail){
    return ExpansionPanelList(

      children: [
        ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Text('Detail');
          },
          body: Text(detail),
          isExpanded: isExpanded,)
      ],
      expansionCallback: (panelIndex, isExpanded) {
        this.isExpanded = !isExpanded;
        setState(() {

        });

      },);

  }
  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Text(widget.model.author),
            SizedBox( width: 500, height : 500,child :imageContent(),),
            imageInformation(imageTitle,imageLike),
            imageDetail(imageDescription),
            imageCommentaire(widget.model.comments)

          ],
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