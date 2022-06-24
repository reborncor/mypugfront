
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pugitem.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:provider/provider.dart';

import '../../features/setting/setting.dart';
import '../../service/themenotifier.dart';
import '../../util/config.dart';
import '../../util/util.dart';
import '../design/design.dart';


class Pug extends StatefulWidget {

  final routeName = '/pug';
  final PugModel? model;
  final String? username;

  const Pug({Key? key, this.model, this.username}) : super(key: key);

  const Pug.withPugModel({Key? key, required this.model, this.username }) : super(key: key);
  const Pug.withPugModelFromOtherUser({Key? key, required this.model,this.username }) : super(key: key);

  @override
  PugState createState() => PugState();
}

class PugState extends State<Pug> {



  late String imageURL;
  late String imageTitle;
  late String imageDescription;
  late int imageLike;
  late ThemeModel notifier;
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
                      Positioned(
                        child: Column(
                          children: [
                            Image( image : AssetImage('asset/images/r-logo.png',), width: 40, height: 40, color: APPCOLOR,),
                            Text((widget.model!.details![i].text) , style: TextStyle(fontSize: 15, color: Colors.white),)],)
                 , left: e.dx, top: e.dy, ),)).values.toList()
                )],),) ,
        ),
      height: 300,
      decoration: BoxDecoration(
          image: DecorationImage(
            image:CachedNetworkImageProvider(URL+"/pugs/"+widget.model!.imageURL),
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
            ],
        )
       
      ],) ,
    );
  }

  //
  // Column(
  // children: [
  // SizedBox( width: 500, height : 500,child :imageContent(imageURL)),
  // imageInformation(imageTitle,imageLike),
  //
  // ],
  // )
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
            actions: [
              IconButton(onPressed: () => navigateTo(context, const Setting()), icon: const Icon(Icons.settings_rounded))
            ],
          ),

          body: Container(
            decoration: BoxGradient(),
            child: Padding( padding: const EdgeInsets.all(3),
              child: Container( child: PugItem.fromProfile(currentUsername: widget.model!.author,model: widget.model!,fromProfile: false),
              //
              // Column(
              // children: [
              // SizedBox( width: 500, height : 500,child :imageContent(imageURL)),
              // imageInformation(imageTitle,imageLike),
              //
              // ],
              // ),
                decoration: BoxCircular(notifier) ,),),
          )

      );
    },);
  }
}

