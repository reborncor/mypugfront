


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

import '../../components/design/design.dart';
import '../../components/pug/api.dart';
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
  late CommentModel comment;
  TextEditingController textEditingController = TextEditingController();
  late List<CommentModel> comments;

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
        comments = snapshot.data!.comments;
        return ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return itemComment(comments[index]);
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

  Widget imageAddComment(String author, String pugId){

    return Padding(padding: EdgeInsets.all(0), child:  Row( children: [
      Expanded(
        child: TextField(
            controller:  textEditingController,
            decoration: InputDecoration(
              suffixIcon:  IconButton(onPressed: () async {
                final result = await sendComment(pugId, author, textEditingController.text);
                if(result.code == SUCCESS_CODE){
                  // showSnackBar(context, "Nouveau commentaire ajouté");
                  comment = CommentModel(id: "", author: _username, content: textEditingController.text, date: "");
                  comments.add(comment);
                  setState(() {
                  });
                  textEditingController.clear();
                }
              } , icon: Icon(Icons.send, color: APPCOLOR,)),
              hintText: "Ajouter un commentaire",
              focusedBorder: setOutlineBorder(1.5, 20.0),
              enabledBorder: setOutlineBorder(1.5, 20.0),
              border:setOutlineBorder(1.5, 20.0),)),),

    ],
    ),);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: APPCOLOR, title: Text("Commentaires"),),
      body: Column(children: [Expanded(child: content()), imageAddComment(widget.username, widget.pugId)], ),
    );
  }
}

