


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

import 'api.dart';


class FollowingView extends StatefulWidget {

  final routeName = '/following';


  const FollowingView({Key? key}) : super(key: key);
  @override
  FollowingViewState createState() => FollowingViewState();
}

class FollowingViewState extends State<FollowingView> {

  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late FollowerResponse _response;
  late String _username;
  late List<UserSearchModel> listFollowing;

  @override
  void initState() {
    fetchData();
    getCurrentUsername().then((value) => _username = value);
    super.initState();

  }


  fetchData() async {
    _response = await getUserFollowings();

  }

  Widget itemFollowing(UserSearchModel model,index){



    return FollowerItem(username: model.username);
  }

  Widget content(){

    return FutureBuilder(

      future: getUserFollowings(),builder: (context, AsyncSnapshot<FollowerResponse>snapshot) {
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
    return Scaffold(
      appBar: AppBar(backgroundColor: APPCOLOR),
      body: content(),
    );
  }
}

