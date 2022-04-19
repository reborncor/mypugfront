
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/features/profile/api.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/userpugresponse.dart';
import 'package:mypug/response/userresponse.dart';
import 'package:mypug/util/util.dart';

class Profile extends StatefulWidget {

  final routeName = '/profile';
  String username ="";

  Profile({Key? key}) : super(key: key);
  Profile.fromUsername({Key? key, required this.username}) : super(key: key);
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {

  List<PugDetailModel> details = [];
  List<PugModel> list = [];
  late Future<UserPugResponse> _response;
  late Future<UserResponse> _userResponse;
   @override
  void initState() {

     if(widget.username == ""){
       _userResponse = getUserInfo();
       _response = getAllPugsFromUser();
     }
     else{
       _userResponse = getUserInfoFromUsername(widget.username);
       _response = getAllPugsFromUsername(widget.username);
     }

    super.initState();

  }


  Widget itemProfile(int data, String text){
    return Column(children: [
      Text(data.toString()),
      Text(text),
    ],);
  }
  Widget profileHeader() {
    return FutureBuilder(future: _userResponse,builder: (context, AsyncSnapshot<UserResponse>snapshot) {
      if(snapshot.hasData) {
        return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(),
            itemProfile(snapshot.data!.pugs,'Publication'),
            itemProfile(snapshot.data!.followers,'Abonnés'),
            itemProfile(snapshot.data!.following,'Abonnement'),

          ],);
      }
      if(snapshot.connectionState == ConnectionState.done){
        return  const Center( child: Text("Aucune donnée"),);
      }
      else{
        return const Center(child : CircularProgressIndicator());
      }


    },);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        backgroundColor: Colors.white,

        body:  Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(child : profileHeader(), width : getPhoneHeight(context), height: 200,),
            Expanded(child: newProfileContent())
          ],
        ))

    );
  }
}
