


import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/followeritem/followeritem.dart';
import 'package:mypug/features/chat/chat.dart';
import 'package:mypug/features/follower/api.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/features/search/api.dart';
import 'package:mypug/models/ConversationModel.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/response/conversationsresponse.dart';
import 'package:mypug/response/followerresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../service/themenotifier.dart';
import 'api.dart';


class FollowingView extends StatefulWidget {

  final routeName = '/following';
  String userSearched = "";

   FollowingView({Key? key}) : super(key: key);
   FollowingView.withName({Key? key, required this.userSearched}) : super(key: key);

  @override
  FollowingViewState createState() => FollowingViewState();
}

class FollowingViewState extends State<FollowingView> {

  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late String _username;
  late List<UserSearchModel> listFollowing;
  late ThemeModel notifier;

  @override
  void initState() {
    log("NAME : "+widget.userSearched);
    getCurrentUsername().then((value) => _username = value);
    super.initState();

  }




  Widget itemFollowing(UserSearchModel model,index){

    return FollowerItem(username: model.username);
  }

  Widget content(){

    return FutureBuilder(

      future: getUserFollowings(widget.userSearched),builder: (context, AsyncSnapshot<FollowerResponse>snapshot) {
      if(snapshot.hasData) {
        listFollowing = snapshot.data!.usernames;
        return ListView.builder(
          itemCount: snapshot.data!.usernames.length,
          itemBuilder: (context, index) {
            return itemFollowing(listFollowing[index], index);
          },);
      }
      if(snapshot.connectionState == ConnectionState.done){
        return  const Center( child: Text("Aucune donnée"),);
      }
      else{
        return const Center(child : CircularProgressIndicator());
      }


    },);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
          appBar: AppBar(
            title: const Text("Abonnement", style: TextStyle(color: Colors.white)),
            backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
          ),

          body:  Container(child : content(), decoration:
                  BoxCircular(notifier),));
    },);
  }
}

