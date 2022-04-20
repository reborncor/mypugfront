
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pugitem.dart';
import 'package:mypug/features/chat/chatlist.dart';
import 'package:mypug/features/search/search.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/actualityresponse.dart';
import 'package:mypug/util/util.dart';

import 'api.dart';

class Actuality extends StatefulWidget {

  final routeName = '/actuality';

  const Actuality({Key? key}) : super(key: key);

  @override
  ActualityState createState() => ActualityState();
}

class ActualityState extends State<Actuality> {


  List<PugDetailModel> details = [];
  List<PugModel> list = [];
  late Future<ActualityResponse> _response;
  late String _username;
  @override
  void initState() {


    fetchData();
    _response = getActuality() as Future<ActualityResponse>;

    super.initState();

  }
  fetchData() async {
     _username = await getCurrentUsername();
    socketService.initialise(_username);
  }

  Widget friendsStory(){
    return Container(height: 50,);
  }
  Widget friendsPug(){
    return ListView(scrollDirection : Axis.vertical,children: list.map((e) => pugItem(e)).toList());
  }
  Widget newFriendsPug(){
    return FutureBuilder(
      future: _response,
      builder: (context, AsyncSnapshot<ActualityResponse>snapshot) {
        if(snapshot.hasData){
          list = snapshot.data!.pugs;
          return ListView.builder(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            scrollDirection: Axis.vertical,
            itemCount : list.length,
            itemBuilder: (context, index) {
              return pugItem(list[index]);
          });
        }
        if(snapshot.connectionState == ConnectionState.done){
          return  const Center( child: Text("Aucune donnée"),);
        }
        else{
          return const Center(child : CircularProgressIndicator());
        }
    },);
  }
  Widget pugItem(PugModel model){
    return Container( width : 400 , height : 700,child : PugItem(model: model,currentUsername: _username,)
    );}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: () {
              navigateWithName(context, const Search().routeName);

            }, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {
              navigateWithName(context, const ChatList().routeName);

            }, icon: const Icon(Icons.send))


          ],
        ),
        backgroundColor: Colors.white,

        body: newFriendsPug(),
        );

  }
}
