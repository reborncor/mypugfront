import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/features/search/api.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/response/userfindresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../service/themenotifier.dart';

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
    if (searchController.text.isNotEmpty) {
      _response = await findAllUsers(searchController.text);
      streamController.add(_response.users);
    }
  }

  Widget searchBar() {
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        fetchData();
      },
      style: TextStyle(color: notifier.isDark ? Colors.white : Colors.black),
      cursorColor: APPCOLOR,
      controller: searchController,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          hintText: "Effectuer une recherche",
          hintStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: APP_COLOR_SEARCH,
          enabledBorder: setUnderlineBorder(2.0, 0.0),
          focusedBorder: setUnderlineBorder(2.0, 0.0),
          suffixIcon: IconButton(
            onPressed: () {
              fetchData();
            },
            icon: Icon(
              Icons.search,
              color: APPCOLOR,
            ),
          )),
    );
  }

  Widget resultComponent() {
    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return const Text("aucunne donnée");
        }

        if (snapshot.hasData) {
          List<UserSearchModel> data = _response.users;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: InkWell(
                    onTap: () {
                      navigateTo(context,
                          Profile.fromUsername(username: data[index].username));
                    },
                    child: ListTile(
                        leading: data[index].profilePicture.isNotEmpty
                            ?ClipRRect(
                            child: Image.network(
                              data[index].profilePicture,
                              width: 40, height: 40,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(100))
                            : Icon(Icons.account_circle),
                        title: Text(data[index].username),
                        trailing: OutlinedButton(
                            onPressed: () {
                              navigateTo(
                                  context,
                                  Profile.fromUsername(
                                      username: data[index].username));
                            },
                            child: Text("Profil")))),
              );
            },
          );
        } else {
          return const SizedBox(
            width: 0,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            appBar: AppBar(
              title: const Text("Recherche"),
              backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
            ),
            body: Container(
              child: Column(
                children: [searchBar(), Expanded(child: resultComponent())],
              ),
              decoration: BoxCircular(notifier),
            ));
      },
    );
  }
}
