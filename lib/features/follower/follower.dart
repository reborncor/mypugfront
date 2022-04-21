


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

import '../../components/design/design.dart';
import 'api.dart';


class FollowersView extends StatefulWidget {

  final routeName = '/follower';


  const FollowersView({Key? key}) : super(key: key);
  @override
  FollowersViewState createState() => FollowersViewState();
}

class FollowersViewState extends State<FollowersView> {

  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late FollowerResponse _response;
  late String _username;

  @override
  void initState() {
    fetchData();
    getCurrentUsername().then((value) => _username = value);
    super.initState();

  }


  fetchData() async {
    _response = await getUserFollowers();

  }

  Widget itemChat(UserSearchModel model){



    return  InkWell(
      onTap:() => navigateTo(context, Profile.fromUsername(username: model.username)),
      child: ListTile(leading: const Icon(Icons.account_circle), title: Text(model.username), trailing: OutlinedButton(onPressed: () {  },
      child: const Text("Consulter")),),);
  }

  Widget content(){

    return FutureBuilder(

      future: getUserFollowers(),builder: (context, AsyncSnapshot<FollowerResponse>snapshot) {
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
    return Scaffold(
      appBar: AppBar(backgroundColor: APPCOLOR,),
      body: content(),
    );
  }
}

