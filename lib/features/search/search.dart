


import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/followeritem/api.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/features/search/api.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/response/userfindresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../service/themenotifier.dart';
import '../follower/api.dart';


class Search extends StatefulWidget {

  final routeName = '/search';


  const Search({Key? key}) : super(key: key);
  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  late ThemeModel notifier;
  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late UserFindResponse _response;

  @override
  void initState() {

    super.initState();

  }




  fetchData() async {
    _response = await findAllUsers(searchController.text);
    streamController.add(_response.usernames);
  }

  Widget searchBar(){

    return TextField(
      style: TextStyle(color: notifier.isDark ? Colors.white : Colors.black),
      cursorColor: APPCOLOR,
      controller: searchController,
      // onChanged: (value){
      //   fetchData();
      // },
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        enabledBorder: setUnderlineBorder(2.0, 0.0),
          focusedBorder: setUnderlineBorder(2.0, 0.0),
          suffixIcon: IconButton(onPressed: () {
        fetchData();

    }, icon: Icon(Icons.search,color: APPCOLOR,),)),);
  }

  Widget resultComponent(){
    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.none){
          return const Text("aucunne donnée");

        }

        if(snapshot.hasData) {
        List<UserSearchModel> data = _response.usernames;
        return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.all(4),
                  child:InkWell( onTap:(){
                    navigateTo(context, Profile.fromUsername(username: data[index].username));
                  },
                    child: ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: Text(data[index].username),
                      trailing: OutlinedButton(
                      onPressed: () {  },
                      child: Text("Profil")))
                    ),);

          },);
        }
        else {
          return Text("Effectuer une recherche",style:  TextStyle(color: notifier.isDark ? Colors.white : Colors.black),);
        }

    },);
  }

  // Column(
  // children: [
  // searchBar(),
  // Expanded(child: resultComponent())
  // ],
  // )
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
          appBar: AppBar(
            title: const Text("Recherche"),
            backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,

          ),

          body: Container(
            decoration: BoxGradient(),
            child: Padding( padding: const EdgeInsets.all(3),
              child: Container( child:
              Column(
              children: [
              searchBar(),
              Expanded(child: resultComponent())
              ],
              ),
                decoration: BoxCircular(notifier) ,),),
          )

      );
    },);

  }
}

