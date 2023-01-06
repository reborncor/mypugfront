
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_mention/instagram_mention.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/pug/api.dart';
import 'package:mypug/features/comment/pugcomments.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../models/CommentModel.dart';
import '../../service/themenotifier.dart';
import '../../util/config.dart';


class PugItem extends StatefulWidget {

  final routeName = '/pugitem';
  final PugModel model;
  final String currentUsername;
  final bool fromProfile;
  const PugItem({Key? key, required this.model, required this.currentUsername, this.fromProfile = false}) : super(key: key);
  const PugItem.fromProfile({Key? key, required this.model, required this.currentUsername, this.fromProfile = true}) : super(key: key);

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


    super.initState();
    imageURL = widget.model.imageURL;
    imageTitle = widget.model.imageTitle!;
    imageDescription = widget.model.imageDescription;
    imageLike = widget.model.like;
    isLiked = widget.model.isLiked;
    if(widget.model.comments.isNotEmpty){
      comment = widget.model.comments.last;
    }
    points.clear();
    for (var element in widget.model.details!) {
      points.add(Offset(element.positionX.toDouble(), element.positionY.toDouble()));
    }

  }





  Widget _typer(String text, isVisible){
    return Container(
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: text.isNotEmpty ? Center( child: InstagramMention(text:text, color: APP_COMMENT_COLOR)) : SizedBox(width: 0,),
      )
    );
  }
  Widget imageContent(){
    return Container(
      child: ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 200, maxHeight: (widget.model.height  > 200)? widget.model.height.toDouble(): 300),
      child: GestureDetector(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                //TODO: replace with animation
                return Center(
                  child: CircularProgressIndicator(
                    color: APPCOLOR,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              image: NetworkImage(widget.model.imageURL ),fit:widget.model.isCrop ? BoxFit.fitWidth : BoxFit.contain,
            ),
            Stack(
                children: points.asMap().map((i,e) => MapEntry(i,
                    Positioned(
                      left: e.dx,
                      top: e.dy,
                      child: Wrap(
                          direction: Axis.vertical,
                          spacing: 1,
                          children: [
                            // widget.fromProfile ? Image( image : const AssetImage('asset/images/r-logo.png',), width: 40, height: 40, color: APPCOLOR,) : SizedBox(width: 0, height: 0,),
                            _typer(widget.model.details![i].text, isVisible),
                          ]),))).values.toList()
            )],),

        onDoubleTap: () async {
          if(!isLiked){
            final result = await likeOrUnlikePug(widget.model.id,widget.model.author, true);
            if(result.code == SUCCESS_CODE){
              imageLike+= 1;
              isLiked = !isLiked;

              setState(() {

              });
            }
          }
        },
        onTap: () {
          isVisible = !isVisible;
          setState(() {

          });
        },),),);


  }


  Widget imageInformation(String title, list){
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(widget.model.numberOfComments.toString(),  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
              ),

              Container(
            width: 30,
            child: Text(imageLike.toString(), style: TextStyle(color: APPCOLOR, fontSize: 20, fontWeight: FontWeight.bold),),
          ),],),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            imageCommentaire(list),
            Column(
              children: [
                IconButton(
                    onPressed: () async {
                      if(!isLiked){
                        final result = await likeOrUnlikePug(widget.model.id,widget.model.author, true);
                        if(result.code == SUCCESS_CODE){
                          // showToast(context, "Vous avez aimé cette image");
                          imageLike+= 1;
                          isLiked = !isLiked;
                        }
                      }
                      else{
                        final result = await likeOrUnlikePug(widget.model.id,widget.model.author, false);
                        if(result.code == SUCCESS_CODE){
                          imageLike-= 1;
                          isLiked = !isLiked;
                        }
                      }
                      setState(() {
                      });

                    }, icon: (isLiked) ?  Icon(Icons.favorite, color: APPCOLOR,) :
                Icon(Icons.favorite_border, color: APPCOLOR,)
                ),
              ],
            )

          ],)
      ]),
    );
  }

  Widget imageCommentaire(List<CommentModel> list){

      return Column(children: [
          GestureDetector(

          onTap: (){
        navigateTo(context, PugComments.withData(pugId: widget.model.id, username: widget.model.author, description : widget.model.imageDescription));
      }, child: Container(
    padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.grey.shade300.withOpacity(0.5)),
    child: Text("commentaires",
    textAlign: TextAlign.center,
    style:TextStyle(fontSize : 19, color: isDarkMode ? Colors.white : Colors.black),),))
      ],);

  }


  Widget imageDetail(String detail){
    return Padding(padding: EdgeInsets.only(left: 8), child:
    Text(
      detail,
      style: TextStyle(color: isDarkMode ? Colors.black : Colors.black), ),);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel  notifier, child) {
      isDarkMode = notifier.isDark;
      return Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              // borderRadius: BorderRadius.circular(10),
              // color: Colors.grey.shade100.withOpacity(0.6)
            ),
            child: Column(
                children: [
          widget.fromProfile ? SizedBox(width: 0,height: 0,) :
            Row( children: [
            const Image( image : AssetImage('asset/images/user.png',), width: 40, height: 40,),
            const SizedBox(width: 10),
            GestureDetector(
            onTap: (){
              navigateTo(context, Profile.fromUsername(username: widget.model.author));},
              child:  Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300.withOpacity(0.6)
                ),
                  child:
              Text(widget.model.author,
                style: TextStyle( fontSize: 20,color: notifier.isDark ? Colors.white :Colors.black),
              )),),],)
          ]),),
          imageContent(),
          imageInformation(imageTitle,widget.model.comments),
          // imageDetail(widget.model.imageDescription!),
          widget.fromProfile ? Padding(
            padding: EdgeInsets.only(top: 20,),
            child:  Center(
              child:ElevatedButton(
                  onPressed: (){showMyDialogDelete("Supprésion", "Vous êtes sur le point de supprimer un pug");},
                  child: Text("Supprimer"), style: BaseButtonRoundedColor(150, 40, APPCOLOR))  ,),):SizedBox(width: 0,height: 10,)

        ],
      );
    },);
  }
  void showMyDialogDelete(String title, String text) {
    showDialog(
        context: context,
        builder: (context) => Center(
            child:AlertDialog(
              title: Text(title),
              content: Text(text),
              actions: [
                ElevatedButton( style: BaseButtonRoundedColor(60,40,APPCOLOR),onPressed: () async {
                  final result = await deletePug(widget.model.id, widget.model.author, widget.model.imageURL);
                  if(result.code == SUCCESS_CODE){
                    showSnackBar(context, result.message);
                    Navigator.pop(context);
                    navigateWithNamePop(context, Profile().routeName);
                  }
                }, child: const Text("Confirmer"),),
            ElevatedButton( style: BaseButtonRoundedColor(60,40,APPCOLOR), onPressed: () => Navigator.pop(context), child: Text("Annuler"))
              ],
            )
        )
    );
  }
}

