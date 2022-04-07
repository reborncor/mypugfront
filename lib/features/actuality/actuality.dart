
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/components/pug/pugitem.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/actualityresponse.dart';

import 'api.dart';

class Actuality extends StatefulWidget {

  final routeName = '/actuality';

  const Actuality({Key? key}) : super(key: key);

  @override
  ActualityState createState() => ActualityState();
}

class ActualityState extends State<Actuality> {


  List<PugDetailModel> details = [];
  PugDetailModel  detailModel= PugDetailModel(text: 'mon texte',positionX: 50, positionY: 70);
  PugModel model1 = PugModel(id: '1', imageURL: 'https://picsum.photos/250?image=1', imageTitle: 'imageTitle', imageDescription: 'imageDescription', details: [], like: 15);
  PugModel model2 = PugModel(id: '1', imageURL: 'https://picsum.photos/250?image=2', imageTitle: 'imageTitle', imageDescription: 'imageDescription', details: [], like: 15);
  PugModel model3 = PugModel(id: '1', imageURL: 'https://picsum.photos/250?image=3', imageTitle: 'imageTitle', imageDescription: 'imageDescription', details: [], like: 15);

  List<PugModel> list = [];
  late Future<ActualityResponse> _response;
  @override
  void initState() {
    model1.details!.add(detailModel);
    model2.details!.add(detailModel);
    model3.details!.add(detailModel);

    list.clear();
    list.add(model1);
    list.add(model2);
    list.add(model3);

    _response = getActuality() as Future<ActualityResponse>;
    super.initState();

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
    return Container( width : 400 , height : 650,child : PugItem(model: model,)
    );}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,

        body: newFriendsPug(),
        );

  }
}
