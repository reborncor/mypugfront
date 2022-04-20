
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/api.dart';
import 'package:mypug/features/comment/pugcomments.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/util/util.dart';
import 'package:readmore/readmore.dart';

import '../../models/CommentModel.dart';


class PugItem extends StatefulWidget {

  final routeName = '/pugitem';
  final PugModel model;
  final String currentUsername;


  const PugItem({Key? key, required this.model, required this.currentUsername}) : super(key: key);
  @override
  PugItemState createState() => PugItemState();
}

class PugItemState extends State<PugItem> {

  late String imageURL;
  late String imageTitle;
  late String imageDescription;
  late int imageLike;
  late List<Offset>points = [];
  TextEditingController textEditingController = TextEditingController();

  late CommentModel comment;
  late bool isLiked;

  bool isExpanded = false;
  bool isVisible = false;
  @override
  void initState() {


    // log(widget.model.id.toString());
    // log(widget.model.author.toString());

    super.initState();
    imageURL = widget.model.imageURL;
    imageTitle = widget.model.imageTitle!;
    imageDescription = widget.model.imageDescription!;
    imageLike = widget.model.like;
    isLiked = widget.model.isLiked;
    if(widget.model.comments.isNotEmpty){
      comment = widget.model.comments.first;
    }
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
  Widget imageInformation(String title){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  if(!isLiked){
                    final result = await likeOrUnlikePug(widget.model.id,widget.model.author, true);
                    if(result.code == SUCCESS_CODE){
                      showSnackBar(context, "image liké");
                      imageLike+= 1;
                      isLiked = !isLiked;
                    }
                  }
                  else{
                    final result = await likeOrUnlikePug(widget.model.id,widget.model.author, false);
                    if(result.code == SUCCESS_CODE){
                      showSnackBar(context, "like retiré");
                      imageLike-= 1;
                      isLiked = !isLiked;
                    }
                  }

                  setState(() {
                  });



                }, icon: (isLiked) ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border)  , label: Text(imageLike.toString(), style: const TextStyle(color: Colors.black),),),
            ],
          )

        ],) ,
    );
  }

  Widget imageCommentaire(List<CommentModel> list){

    if(list.isEmpty){
      return SizedBox.fromSize(size: const Size(0,0));
    }

    return Padding(padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [ Text(comment.author),
              Padding(padding: const EdgeInsets.all(8) , child : Text(comment.content, maxLines: 1,      overflow: TextOverflow.ellipsis,)),],),

            Expanded(flex : 0,child: TextButton(onPressed: (){navigateTo(context, PugComments.withData(pugId: widget.model.id, username: widget.model.author));}, child: const Text("commentaires")))

      ],));
  }

  Widget imageDetail(String detail){
    return ReadMoreText(detail, trimLines : 3,trimCollapsedText: "Voir plus",trimExpandedText: "Moins",);


  }

  Widget imageAddComment(String author, String pugId){

    return Padding(padding: EdgeInsets.all(0), child:  Row( children: [
      Expanded(child: TextField(controller:  textEditingController, decoration: const InputDecoration(hintText: "Ajouter un commentaire")),),
      IconButton(onPressed: () async {
        final result = await sendComment(pugId, author, textEditingController.text);
        if(result.code == SUCCESS_CODE){
          showSnackBar(context, "Nouveau commentaire ajouté");
          comment.author = widget.currentUsername;
          comment.content = textEditingController.text;
          setState(() {
          });
          textEditingController.clear();
        }
        } , icon: const Icon(Icons.send))
    ],
    ),);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Text(widget.model.author),
            SizedBox( width: 500, height : 500,child :imageContent(),),
            imageInformation(imageTitle),
            imageDetail(imageDescription),
            imageCommentaire(widget.model.comments),
            imageAddComment(widget.model.author, widget.model.id),


          ],
        );
  }

  max(int i, maxHeight) {}
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