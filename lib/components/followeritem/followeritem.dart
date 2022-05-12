
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/api.dart';
import 'package:mypug/features/comment/pugcomments.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import '../../features/profile/profile.dart';
import '../../models/CommentModel.dart';
import 'api.dart';


class FollowerItem extends StatefulWidget {

  final routeName = '/pugitem';
  final String username;


  const FollowerItem({Key? key,required this.username, }) : super(key: key);
  @override
  FollowerItemState createState() => FollowerItemState();
}

class FollowerItemState extends State<FollowerItem> {

  String text = "Se désabonner";
  bool follow = true;
  late ThemeModel notfier;
  @override
  void initState() {

    super.initState();


  }








  @override
  Widget build(BuildContext context) {

    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      notfier = notifier;
      return InkWell(
        onTap:() => navigateTo(context, Profile.fromUsername(username:widget.username)),


        child: ListTile(leading: const Image(image: AssetImage("asset/images/user.png"),width: 40, height: 40,), title: Text(widget.username, style: TextStyle(color:  this.notfier.isDark ? Colors.white : Colors.black),), trailing: OutlinedButton(child: Text(text), onPressed:() async {


          final result = await unFollowOrFollowUser(widget.username, follow);
          if(result.code == SUCCESS_CODE){
            follow = !follow;
            text = follow ? "Se désabonner":"S'abonner";
            setState(() {

            });
          }
        },)),);
    },);
  }
}


