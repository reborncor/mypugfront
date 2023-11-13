import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/blockeditem/blockeditem.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/followeritem/followeritem.dart';
import 'package:mypug/features/userblocked/api.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/response/followerresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../service/themenotifier.dart';

class UsersBlockedView extends StatefulWidget {
  final routeName = '/usersblocked';
  String userSearched = "";

  UsersBlockedView({Key? key}) : super(key: key);

  @override
  UsersBlockedViewState createState() => UsersBlockedViewState();
}

class UsersBlockedViewState extends State<UsersBlockedView> {
  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late List<UserSearchModel> listOfUsersBlocked;
  late ThemeModel notifier;

  @override
  void initState() {
    super.initState();
  }

  Widget itemBlocked(UserSearchModel model, index) {
    return BlockedItem(user: model);
  }

  Widget content() {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: FutureBuilder(
        future: getUserBlocked(),
        builder: (context, AsyncSnapshot<FollowerResponse> snapshot) {
          if (snapshot.hasData) {
            listOfUsersBlocked = snapshot.data!.users;
            if (snapshot.data!.users.length == 0) {
              return const Center(child: Text("Aucun utilisateur bloqué"));
            }
            return ListView.builder(
              itemCount: snapshot.data!.users.length,
              itemBuilder: (context, index) {
                return itemBlocked(listOfUsersBlocked[index], index);
              },
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data);

            return  Center(
              child: Text(sentence_no_data),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> onRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            appBar: AppBar(
              title: const Text("Utilisateurs bloqués",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
            ),
            body: Container(
              child: content(),
              decoration: BoxCircular(notifier),
            ));
      },
    );
  }
}
