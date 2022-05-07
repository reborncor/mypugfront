
import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/pug/pugitem.dart';
import 'package:mypug/features/chat/chatlist.dart';
import 'package:mypug/features/search/search.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/actualityresponse.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

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
  late ActualityResponse _response;
  late String _username;
  late ScrollController scrollController = ScrollController();
  late int startInd = 0;
  late int endInd = 4;
  StreamController streamController = StreamController();
  @override
  void initState() {

    fetchData();
    // _response = getActuality() as Future<ActualityResponse>;
    scrollController.addListener(scrollListener);
    super.initState();

  }

  fetchData() async {
     _username = await getCurrentUsername();
     _response = await getActualityPageable(startInd, endInd);
     startInd+=4;
     endInd+=4;
     list = _response.pugs;
     streamController.add("event");
    socketService.initialise(_username);
  }

  fetchOldActuality() async {
    _response = await getActualityPageable(startInd, endInd);
    list.addAll(_response.pugs);
    startInd+=4;
    endInd+=4;
    streamController.add("event");
  }

  scrollListener(){
    // log("POSITION : "+scrollController.position.toString());
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      fetchOldActuality();
      log("reach the bottom");

    }
    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
    }

  }



  Future<void> refreshData() async {
    startInd = 0;
    endInd = startInd+4;
    _response = await getActualityPageable(startInd, endInd);
    list = _response.pugs;
    streamController.add("event");
  }

  Widget newFriendsPug(){
    return RefreshIndicator(child: StreamBuilder(
      stream : streamController.stream,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ListView.builder(
              controller: scrollController,
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
          return  Center(child : CircularProgressIndicator(color: APPCOLOR,));
        }
      },), onRefresh: refreshData);
  }
  Widget pugItem(PugModel model){
    return Container(
        decoration : BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 1,
                    color: APPCOLOR))),
        width : 400 ,
        height : 700,

        child : PugItem(model: model,currentUsername: _username,)
    );}
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Actualité"),
          automaticallyImplyLeading: false,

          backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
          actions: [
            IconButton(onPressed: () {
              navigateWithName(context, const Search().routeName);

            }, icon: const Icon(Icons.search)),

          ],
        ),

        body: Container(
          decoration: BoxGradient(),
            child : Padding( padding: const EdgeInsets.all(3),
                child : Container(child : newFriendsPug(), decoration:
                BoxCircular(notifier),)  )));
    },);

  }
}
