
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/followeritem/api.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/features/chat/chat.dart';
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
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  late bool isFollowing = false;
  late ThemeModel notifier;
  final RefreshController _refreshController = RefreshController();
  late ScrollController scrollController = ScrollController(initialScrollOffset: 200);

  @override
  void initState() {
   fetchData();
    super.initState();

  }


  fetchData(){
    if(widget.username == ""){
      _userResponse = getUserInfo();
      _response = getAllPugsFromUser();

    }
    else{
      _userResponse = getUserInfoFromUsername(widget.username);
      _response = getAllPugsFromUsername(widget.username);
    }

  }



  Widget itemProfile(int data, String text){
    return Container( height : 50,child : Column(children: [
      Text(data.toString(), style: TextStyle(fontSize: 20, color: notifier.isDark ? Colors.white : Colors.black),),
      Text(text, style: TextStyle(color: notifier.isDark ? Colors.white : Colors.black),),
    ],));
  }
  Widget profileHeader() {
    return FutureBuilder(future: _userResponse,builder: (context, AsyncSnapshot<UserResponse>snapshot) {
      if(snapshot.hasData) {
        username = snapshot.data!.username;
        isFollowing = snapshot.data!.isFollowing ?? false;
        String textButton = isFollowing ? "Se désabonner":"S'abonner";
        if(widget.username != ""){


        }


        return
             Column(children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Column(children: [
              const SizedBox(height : 150, width : 120,child: CircleAvatar(backgroundColor: Colors.transparent,    maxRadius: 100,
                minRadius: 100,
                child:
                Image( image : AssetImage('asset/images/user.png',), width: 120, height: 120,),
              ),),
              Text(username, style: TextStyle(fontSize: 18, color: notifier.isDark ? Colors.white : Colors.black),),
            ]),
            itemProfile(snapshot.data!.pugs,'Publication'),

            InkWell(child :  itemProfile(snapshot.data!.followers,'Abonnés'), onTap: (){navigateWithName(context, const FollowersView().routeName);},),
            InkWell( child: itemProfile(snapshot.data!.following,'Abonnement'), onTap:(){navigateWithName(context, const FollowingView().routeName);},)


          ],),
          (widget.username == "") ? SizedBox(width: 0,height: 0,) :  Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                  style: BaseButtonSize(150, 30 , Colors.transparent),

                  onPressed: () async {
                      final result = await unFollowOrFollowUser(username, isFollowing);
                      if(result.code == SUCCESS_CODE){
                        log(result.message);
                        isFollowing = !isFollowing;
                        await fetchData();
                        setState(() {

                        });
                      }

                  }, child: Text(textButton )),
              OutlinedButton(
                  style: BaseButtonSize(150, 30 , Colors.transparent),
                  onPressed: () {
                    navigateTo(context, Chat.withUsername(receiverUsername: username));
                  }, child: Text("Message")),
            ],)
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


  Widget imageItemBuffer(PugModel model){
    
    return InkWell(
      child: Container( decoration : BoxDecoration(border: Border.all(color : Colors.black)),child :Image.memory(base64Decode(model.imageData), fit: BoxFit.fitWidth)),
      onTap: (){
        navigateTo(context, Pug.withPugModel(model: model,));
      },
    );
  }

  Widget newProfileContent(){
    return FutureBuilder(
      future: _response ,
      builder: (context, AsyncSnapshot<UserPugResponse> snapshot) {
        if(snapshot.hasData){

            list = snapshot.data!.pugs;
            String pathImage = notifier.isDark? "asset/images/logo-header-dark.png":"asset/images/logo-header-light.png";
            return  Container(
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage(pathImage))),
              child: GridView.builder(
                  shrinkWrap: true, // You won't see infinite size error
                  physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
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
  Future<void> refreshData() async {
    if(widget.username == ""){
      _userResponse = getUserInfo();

      _response = getAllPugsFromUser();
    }
    else{
      _userResponse = getUserInfoFromUsername(widget.username);

      _response = getAllPugsFromUsername(widget.username);

    }
    _refreshController.refreshCompleted();
    scrollController.animateTo(
        200,
        duration: Duration(milliseconds: 1000),
        curve: Curves.ease);
    setState(() {

    });

  }

  Widget background(){
    return SliverAppBar(
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(
          background: Image.network(
            "https://images.unsplash.com/photo-1541701494587-cb58502866ab?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=0c21b1ac3066ae4d354a3b2e0064c8be&auto=format&fit=crop&w=500&q=60",
            fit: BoxFit.cover,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,

          title: const Text("Profile"),
          backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
          actions: [
            IconButton(onPressed: () => navigateTo(context, const Setting()), icon: const Icon(Icons.settings_rounded))
          ],
        ),
          body: Container(
                  decoration: BoxGradient(),
                child: Padding(padding: const EdgeInsets.all(3),
                  child: Container
                    (child: content() , decoration: BoxCircular(notifier),),),),);

    },);
  }

  Widget content(){
    String pathImage = notifier.isDark? "asset/images/logo-header-dark.png":"asset/images/logo-header-light.png";

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: refreshData,
      child:  CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(expandedHeight: 150,
            automaticallyImplyLeading: false,
            backgroundColor: notifier.isDark ? Colors.black : Colors.transparent,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(

              background: Image.asset(pathImage, fit: BoxFit.fitWidth,),
            ),),
          SliverFillRemaining(

            child :SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [ Container(child : profileHeader(), width : getPhoneWidth(context), height: 250,),
                newProfileContent()],),),),]),);

  }
}


