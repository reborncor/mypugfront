
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/components/pug/pugitem.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';

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
  @override
  void initState() {
    model1.details!.add(detailModel);
    model2.details!.add(detailModel);
    model3.details!.add(detailModel);

    list.clear();
    list.add(model1);
    list.add(model2);
    list.add(model3);

    super.initState();

  }


  Widget friendsStory(){
    return Container(height: 50,);
  }
  Widget friendsPug(){
    return ListView(scrollDirection : Axis.vertical,children: list.map((e) => pugItem(e)).toList());
  }
  Widget pugItem(PugModel model){
    return Container( width : 400 , height : 650,child : PugItem(pugModel: model,)
    );}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,

        body: friendsPug(),
        );

  }
}
