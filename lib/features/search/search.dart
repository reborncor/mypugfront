


import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/features/search/api.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/response/userfindresponse.dart';
import 'package:mypug/util/util.dart';


class Search extends StatefulWidget {

  final routeName = '/search';


  const Search({Key? key}) : super(key: key);
  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {

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
      controller: searchController,
      // onChanged: (value){
      //   fetchData();
      // },
      textAlign: TextAlign.center,
      decoration: InputDecoration(suffixIcon: IconButton(onPressed: () {
        fetchData();

    }, icon: const Icon(Icons.search),)),);
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
                    child: ListTile(leading: const Icon(Icons.account_circle), title: Text(data[index].username)),));

          },);
        }
        else {
          return const Text("Effectuer une recherche");
        }

    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: APPCOLOR,),
      body: Column(
        children: [
          searchBar(),
          Expanded(child: resultComponent())
        ],
      )
    );
  }
}

