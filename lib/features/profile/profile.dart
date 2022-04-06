
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/features/profile/api.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/userpugresponse.dart';
import 'package:mypug/util/util.dart';

class Profile extends StatefulWidget {

  final routeName = '/profile';

  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {

  List<PugDetailModel> details = [];
  List<PugModel> list = [];
  late Future<UserPugResponse> _response;
  PugDetailModel  detailModel= PugDetailModel(text: 'mon texte',id: '',positionX: 50.0, positionY: 70.0);
  PugModel model1 = PugModel(id: '1', imageURL: 'https://picsum.photos/250?image=1', imageTitle: 'MY PUG 1', imageDescription: 'imageDescription', details: [], like: 15);
  PugModel model2 = PugModel(id: '1', imageURL: 'https://picsum.photos/250?image=2', imageTitle: 'MY PUG 2', imageDescription: 'imageDescription', details: [], like: 15);
  PugModel model3 = PugModel(id: '1', imageURL: 'https://picsum.photos/250?image=3', imageTitle: 'MY PUG 3', imageDescription: 'imageDescription', details: [], like: 15);
  @override
  void initState() {

    model1.details!.add(detailModel);
    model2.details!.add(detailModel);
    model3.details!.add(detailModel);

    list.clear();
    list.add(model1);
    list.add(model2);
    list.add(model3);

    _response = getAllPugsFromUser();
    super.initState();

  }
  
  Widget profileHeader() {
    return const Center( child: Text('Test'),);
  }

  Widget imageItem(PugModel model){
    return GestureDetector(
      child: Image.network(model.imageURL),
      onTap: (){
          navigateTo(context, Pug(model: model,));
      },
    );
  }
  Widget imageItemBuffer(PugModel model){
    
    return GestureDetector(
      child: Image.memory(base64Decode(model.imageData)),
      onTap: (){
        navigateTo(context, Pug(model: model,));
      },
    );
  }

  Widget newProfileContent(){
    return FutureBuilder(
      future: _response ,
      builder: (context, AsyncSnapshot<UserPugResponse> snapshot) {
        if(snapshot.hasData){
            list = snapshot.data!.pugs;
            return GridView.builder(
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
                ), itemBuilder: (context, index){
                return imageItemBuffer(list[index]);
            }
            );
        }
        if(snapshot.connectionState == ConnectionState.done){
          return  const Center( child: Text("Aucune donnée"),);
        }
        else{
          return const Center(child : CircularProgressIndicator());
        }

    },);
  }
  Widget profileContent() {

    return GridView(gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
    ),
      children: [
        imageItem(model1),
        imageItem(model2),
        imageItem(model3),
        imageItem(model1),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        backgroundColor: Colors.white,

        body:  Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            profileHeader(),
            Expanded(child: newProfileContent())
          ],
        ))

    );
  }
}
