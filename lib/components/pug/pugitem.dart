
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/pug/api.dart';
import 'package:mypug/features/comment/pugcomments.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import '../../models/CommentModel.dart';
import '../../service/themenotifier.dart';


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
  late bool isDarkMode;
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
              fit: BoxFit.contain,
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



                }, icon: (isLiked) ?  Icon(Icons.favorite, color: APPCOLOR,) :  Icon(Icons.favorite_border, color: APPCOLOR,)  , label: Text(imageLike.toString(), style: TextStyle(color: APPCOLOR),),),
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

            Expanded(flex : 0,child: TextButton(
              
                onPressed: (){
                  navigateTo(context, PugComments.withData(pugId: widget.model.id, username: widget.model.author));
                  }, child: Text("commentaires", style: TextStyle(color: APPCOLOR),)))

      ],));
  }

  Widget imageDetail(String detail){
    return ReadMoreText(detail, trimLines : 1,trimCollapsedText: "Voir plus",trimExpandedText: "Moins",  colorClickableText: APPCOLOR,
      trimMode: TrimMode.Line, );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel  notifier, child) {
      isDarkMode = notifier.isDark;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( children: [const Image( image : AssetImage('asset/images/user.png',), width: 40, height: 40,),const SizedBox(width: 10),  Text(widget.model.author, style: TextStyle(fontWeight: FontWeight.bold),),],),
          SizedBox( width: 500, height : 500,child :imageContent(),),
          imageInformation(imageTitle),
          imageDetail(imageDescription),
          imageCommentaire(widget.model.comments),
          // imageAddComment(widget.model.author, widget.model.id),


        ],
      );
    },);
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