
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


    // log(widget.model.id.toString());
    // log(widget.model.author.toString());

    super.initState();
    imageURL = widget.model.imageURL;
    imageTitle = widget.model.imageTitle!;
    imageDescription = widget.model.imageDescription!;
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




  // Widget _typer(String text){
  //   return SizedBox(
  //     width: 100,
  //     child: DefaultTextStyle(
  //       style:  TextStyle(fontSize: 15, color: Colors.white),
  //       child: AnimatedTextKit(
  //           isRepeatingAnimation: false,
  //           animatedTexts: [
  //             TyperAnimatedText(text
  //                 ,speed: Duration(milliseconds: 100)),
  //
  //           ]
  //       ),
  //     ),
  //   );
  // }


  Widget _typer(String text, isVisible){
    return SizedBox(
      width: 100,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: InstagramMention(text: text, color: APP_COMMENT_COLOR),
      )
    );
  }
  Widget imageContent(){
    log(widget.model.toString());
    return GestureDetector(
      child: AspectRatio(
        aspectRatio: 4/5,
        child: Container(
        child: Stack(
            children: [
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
        height: 300,

        decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(URL+"/pugs/"+widget.model.imageURL ),
              fit: widget.model.isCrop ? BoxFit.fitWidth : BoxFit.contain,
            )
        ),
      ),),
      onDoubleTap: () async {
        if(!isLiked){
          final result = await likeOrUnlikePug(widget.model.id,widget.model.author, true);
          if(result.code == SUCCESS_CODE){
            showToast(context, "Vous avez aimé cette image");
            imageLike+= 1;
            isLiked = !isLiked;
          }
        }
      },
      onTap: () {
      isVisible = !isVisible;
      setState(() {

      });
    },);

  }
  Widget imageInformation(String title){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  if(!isLiked){
                    final result = await likeOrUnlikePug(widget.model.id,widget.model.author, true);
                    if(result.code == SUCCESS_CODE){
                      showToast(context, "Vous avez aimé cette image");
                      imageLike+= 1;
                      isLiked = !isLiked;
                    }
                  }
                  else{
                    final result = await likeOrUnlikePug(widget.model.id,widget.model.author, false);
                    if(result.code == SUCCESS_CODE){
                      // showToast(context, "Like reti")
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
      return  Expanded(flex : 0,child: TextButton(

          onPressed: (){
            navigateTo(context, PugComments.withData(pugId: widget.model.id, username: widget.model.author));
          }, child: Text("Ajouter un commentaire..",
        style:TextStyle(color: isDarkMode ? Colors.white : Colors.black),)))
      ;
    }

    return Padding(padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [ Text(comment.author, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),),
              Padding(padding: const EdgeInsets.all(8) , child : Text(comment.content, maxLines: 1, style: TextStyle(color : isDarkMode ? Colors.white : Colors.black),     overflow: TextOverflow.ellipsis,)),],),

            Expanded(flex : 0,child: TextButton(
              
                onPressed: (){
                  navigateTo(context, PugComments.withData(pugId: widget.model.id, username: widget.model.author));
                  }, child: Text("commentaires", style: TextStyle(color: APPCOLOR),)))

      ],));
  }

  Widget imageDetail(String detail){
    return Padding(padding: EdgeInsets.only(left: 8), child:  ReadMoreText(detail, trimLines : 1,trimCollapsedText: "Voir plus",trimExpandedText: "Moins",  colorClickableText: APPCOLOR,
      trimMode: TrimMode.Line,style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), ),);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel  notifier, child) {
      isDarkMode = notifier.isDark;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.fromProfile ? SizedBox(width: 0,height: 10,) :
          Row( children: [
            const Image( image : AssetImage('asset/images/user.png',), width: 40, height: 40,),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: (){
                navigateTo(context, Profile.fromUsername(username: widget.model.author));},
              child:  Text(widget.model.author,
                style: TextStyle(fontWeight: FontWeight.bold, color: notifier.isDark ? Colors.white :Colors.black),
              ),),],) ,
          SizedBox( width: 500, height : PUGSIZE,child :imageContent(),),
          imageInformation(imageTitle),
          imageDetail(imageDescription),
          imageCommentaire(widget.model.comments),
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
                  final result = await deletePug(widget.model.id, widget.model.author);
                  if(result.code == SUCCESS_CODE){
                    showSnackBar(context, result.message);
                    Navigator.pop(context);
                    navigateTo(context, Profile());
                  }
                }, child: const Text("Confirmer"),),
            ElevatedButton( style: BaseButtonRoundedColor(60,40,APPCOLOR), onPressed: () => Navigator.pop(context), child: Text("Annuler"))
              ],
            )
        )
    );
  }
}

