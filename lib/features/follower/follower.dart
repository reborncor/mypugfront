


import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/features/chat/chat.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/features/search/api.dart';
import 'package:mypug/models/ConversationModel.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/response/conversationsresponse.dart';
import 'package:mypug/response/followerresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../components/design/design.dart';
import '../../service/themenotifier.dart';
import 'api.dart';


class FollowersView extends StatefulWidget {

  final routeName = '/follower';
  String userSearched ="";

  FollowersView({Key? key}) : super(key: key);
  FollowersView.withName({Key? key, required this.userSearched}) : super(key: key);

  @override
  FollowersViewState createState() => FollowersViewState();

}

class FollowersViewState extends State<FollowersView> {

  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late FollowerResponse _response;
  late String _username;
  late ThemeModel notifier;

  @override
  void initState() {
    getCurrentUsername().then((value) => _username = value);
    super.initState();

  }


  Widget itemChat(UserSearchModel model){



    return  InkWell(
      onTap:() => navigateTo(context, Profile.fromUsername(username: model.username)),
      child: ListTile(leading: const Icon(Icons.account_circle), title: Text(model.username), trailing: OutlinedButton(onPressed: () {navigateTo(context, Profile.fromUsername(username: model.username));  },
      child: const Text("Consulter", style: TextStyle(color: Colors.white))),),);
  }

  Widget content(){

    return FutureBuilder(

      future: getUserFollowers(widget.userSearched),builder: (context, AsyncSnapshot<FollowerResponse>snapshot) {
      if(snapshot.hasData) {
        log(snapshot.data!.usernames.length.toString());
        return ListView.builder(
          itemCount: snapshot.data!.usernames.length,
          itemBuilder: (context, index) {
            return itemChat(snapshot.data!.usernames[index]);
          },);
      }
      if(snapshot.connectionState == ConnectionState.done){
        return  const Center( child: Text("Aucune donnée"),);
      }
      else{
        return Center(child : CircularProgressIndicator(color: APPCOLOR,));
      }


    },);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
          appBar: AppBar(

            title: const Text("Abonnés", style: TextStyle(color: Colors.white)),
            backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
          ),

          body: Container(child : content(), decoration:
          BoxCircular(notifier),));
    },);;
  }
}

