import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/followeritem/followeritem.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/response/followerresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../service/themenotifier.dart';
import '../profile/profile.dart';
import 'api.dart';

class FollowingView extends StatefulWidget {
  final routeName = '/following';
  String userSearched = "";
  bool isOwner = false;

  FollowingView({Key? key}) : super(key: key);

  FollowingView.withName(
      {Key? key, required this.userSearched, required this.isOwner})
      : super(key: key);

  @override
  FollowingViewState createState() => FollowingViewState();
}

class FollowingViewState extends State<FollowingView> {
  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late String _username;
  late List<UserSearchModel> listFollowing;
  late ThemeModel notifier;

  @override
  void initState() {
    getCurrentUsername().then((value) => _username = value);
    super.initState();
  }

  Widget itemFollowing(UserSearchModel model, index) {
    if (widget.isOwner) {
      return FollowerItem(user: model);

    }else{
      return InkWell(
        onTap: () =>
            model.username == _username ? navigateWithName(context, Profile().routeName) : navigateTo(context, Profile.fromUsername(username: model.username)),
        child: ListTile(
          leading: renderProfilePicture(
              model.profilePicture, model.profilePicture.isNotEmpty, 40),
          title: Text(model.username),
          trailing: OutlinedButton(
              onPressed: () {
                navigateTo(
                    context, Profile.fromUsername(username: model.username));
              },
              child: const Text("Consulter",
                  style: TextStyle(color: Colors.white))),
        ),
      );
    }

  }

  Widget content() {
    return FutureBuilder(
      future: getUserFollowings(widget.userSearched),
      builder: (context, AsyncSnapshot<FollowerResponse> snapshot) {
        if (snapshot.hasData) {
          listFollowing = snapshot.data!.users;
          return ListView.builder(
            itemCount: snapshot.data!.users.length,
            itemBuilder: (context, index) {
              return itemFollowing(listFollowing[index], index);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            appBar: AppBar(
              title: const Text("Abonnement",
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
