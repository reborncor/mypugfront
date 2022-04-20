


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
import 'package:mypug/util/util.dart';

import 'api.dart';


class ChatList extends StatefulWidget {

  final routeName = '/chatlist';


  const ChatList({Key? key}) : super(key: key);
  @override
  ChatListState createState() => ChatListState();
}

class ChatListState extends State<ChatList> {

  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late ConversationsResponse _response;
  late String _username;

  @override
  void initState() {
    fetchData();
    getCurrentUsername().then((value) => _username = value);
    super.initState();

  }


  fetchData() async {
    _response = await getUserConversations();

  }

  Widget itemChat(ConversationModel model){

    String receiverUserame = model.members.first == _username ? model.members.last : model.members.first;


    return  InkWell( 
      onTap:() => navigateTo(context, Chat.withUsername(receiverUsername: receiverUserame)),
      child: ListTile(
      leading: const Image( image : AssetImage('asset/images/user.png',), width: 40, height: 40,),
      trailing: const Icon(Icons.send),
      title: Text(receiverUserame,style: const TextStyle(fontSize: 17), ),
      subtitle: Text((model.chat.first.content),
      ),
    ),);
  }

  Widget content(){

    return FutureBuilder(

      future: getUserConversations(),builder: (context, AsyncSnapshot<ConversationsResponse>snapshot) {
      if(snapshot.hasData) {
        log(snapshot.data!.conversations.length.toString());
        return ListView.builder(
          itemCount: snapshot.data!.conversations.length,
          itemBuilder: (context, index) {
          return itemChat(snapshot.data!.conversations[index]);
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

