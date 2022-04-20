


import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/features/chat/chat.dart';
import 'package:mypug/models/CommentModel.dart';

import 'package:mypug/models/ConversationModel.dart';
import 'package:mypug/response/commentresponse.dart';
import 'package:mypug/response/conversationsresponse.dart';
import 'package:mypug/util/util.dart';

import 'api.dart';


class PugComments extends StatefulWidget {

  final routeName = '/pugcomments';
  final String pugId;
  final String username;

  const PugComments({Key? key, this.pugId = "", this.username = ""}) : super(key: key);
  const PugComments.withData({Key? key, required this.pugId, required this.username});

  @override
  PugCommentsState createState() => PugCommentsState();
}

class PugCommentsState extends State<PugComments> {

  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late CommentResponse _response;
  late String _username;


  @override
  void initState() {
    // fetchData();
    getCurrentUsername().then((value) => _username = value);
    super.initState();

  }


  fetchData() async {
    _response = await getPugComment(widget.pugId, widget.username);
  }

  Widget itemComment(CommentModel model){


    return  InkWell(
      child: Row(
        children: [
          const Image( image : AssetImage('asset/images/user.png',), width: 40, height: 40,),
          Text(model.author),
          Text(model.content),
        ],

    )
    );
  }

  Widget content(){

    return FutureBuilder(

      future: getPugComment(widget.pugId, widget.username),
      builder: (context, AsyncSnapshot<CommentResponse>snapshot) {
      if(snapshot.hasData) {
        log(snapshot.data!.comments.length.toString());
        return ListView.builder(
          itemCount: snapshot.data!.comments.length,
          itemBuilder: (context, index) {
            return itemComment(snapshot.data!.comments[index]);
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
      appBar: AppBar(),
      body: content(),
    );
  }
}

