
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/features/follower/follower.dart';
import 'package:mypug/features/following/following.dart';
import 'package:mypug/features/profile/api.dart';
import 'package:mypug/features/setting/setting.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/userpugresponse.dart';
import 'package:mypug/response/userresponse.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

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
  late String username;
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
    return Container( height : 50,child : Column(children: [
      Text(data.toString(), style: const TextStyle(fontSize: 20),),
      Text(text),
    ],));
  }
  Widget profileHeader() {
    return FutureBuilder(future: _userResponse,builder: (context, AsyncSnapshot<UserResponse>snapshot) {
      if(snapshot.hasData) {
        username = snapshot.data!.username;
        return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Column(children: [
            const SizedBox(height : 150, width : 120,child: CircleAvatar(backgroundColor: Colors.transparent,    maxRadius: 100,
                minRadius: 100,
                child:
                  Image( image : AssetImage('asset/images/user.png',), width: 120, height: 120,),
                ),),
              Text(username, style: TextStyle(fontSize: 18),),
            ]),
            itemProfile(snapshot.data!.pugs,'Publication'),

            InkWell(child :  itemProfile(snapshot.data!.followers,'Abonnés'), onTap: (){navigateWithName(context, const FollowersView().routeName);},),
            InkWell( child: itemProfile(snapshot.data!.following,'Abonnement'), onTap:(){navigateWithName(context, const FollowingView().routeName);},)


          ],);
      }
      if(snapshot.connectionState == ConnectionState.done){
        return  const Center( child: Text("Aucune donnée"),);
      }
      else{
        return Center(child : CircularProgressIndicator(color: APPCOLOR,));
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
    
    return InkWell(
      child: Container( decoration : BoxDecoration(border: Border.all(color : Colors.black)),child :Image.memory(base64Decode(model.imageData), fit: BoxFit.fitWidth)),
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
            return Container(
              child: GridView.builder(

                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ), itemBuilder: (context, index){
              return imageItemBuffer(list[index]);
            }
            ),);
        }
        if(snapshot.connectionState == ConnectionState.done){

          return  const Center( child: Text(""),);
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return  const Center( child: Text(""),);
        }
        else{
          return Center(child : CircularProgressIndicator(color: APPCOLOR,));
        }

    },);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, value, child) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: APPCOLOR,
            actions: [
              IconButton(onPressed: () => navigateTo(context, const Setting()), icon: const Icon(Icons.settings_rounded))
            ],
          ),

          body:  Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(child : profileHeader(), width : getPhoneHeight(context), height: 200,),
              Expanded(child: newProfileContent())
            ],
          ))

      );
    },);
  }
}
