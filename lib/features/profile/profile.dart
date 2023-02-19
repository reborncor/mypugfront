import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/followeritem/api.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/features/actuality/actuality.dart';
import 'package:mypug/features/actualityall/actualityall.dart';
import 'package:mypug/features/chat/chat.dart';
import 'package:mypug/features/follower/follower.dart';
import 'package:mypug/features/following/following.dart';
import 'package:mypug/features/profile/api.dart';
import 'package:mypug/features/setting/setting.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/userpugresponse.dart';
import 'package:mypug/response/userresponse.dart';
import 'package:mypug/service/api/blockuser.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Profile extends StatefulWidget {
  final routeName = '/profile';
  String username = "";

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
  late String profilePicture;
  late bool isFollowing = false;
  late ThemeModel notifier;
  final RefreshController _refreshController = RefreshController();
  late ScrollController scrollController =
      ScrollController(initialScrollOffset: 200);
  late bool hasBackButton = false;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() {
    if (widget.username == "") {
      _userResponse = getUserInfo();
      _response = getAllPugsFromUser();
    } else {
      _userResponse = getUserInfoFromUsername(widget.username);
      _response = getAllPugsFromUsername(widget.username);
      hasBackButton = true;
      setState(() {});
    }
  }

  Widget itemProfile(int data, String text) {
    return Container(
        height: 50,
        child: Column(
          children: [
            Text(
              data.toString(),
              style: TextStyle(
                  fontSize: 20,
                  color: notifier.isDark ? Colors.white : Colors.black),
            ),
            Text(
              text,
              style: TextStyle(
                  color: notifier.isDark ? Colors.white : Colors.black),
            ),
          ],
        ));
  }

  Widget profileHeader() {
    return FutureBuilder(
      future: _userResponse,
      builder: (context, AsyncSnapshot<UserResponse> snapshot) {
        if (snapshot.hasData) {
          username = snapshot.data!.username;
          profilePicture = snapshot.data!.profilePicture;
          isFollowing = snapshot.data!.isFollowing ?? false;
          String textButton = isFollowing ? "Se désabonner" : "S'abonner";
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(children: [
                    SizedBox(
                      height: 150,
                      width: 120,
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 100,
                        child: profilePicture.isNotEmpty
                            ? ClipRRect(
                                child: Image.network(
                                  snapshot.data!.profilePicture,
                                  width: 100,
                                  height: 100,
                                ),
                                borderRadius: BorderRadius.circular(100))
                            : const Image(
                                fit: BoxFit.contain,
                                image: AssetImage(
                                  'asset/images/user.png',
                                ),
                              ),
                      ),
                    ),
                    Text(
                      username,
                      style: TextStyle(
                          fontSize: 18,
                          color: notifier.isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade100.withOpacity(0.2),
                    ),
                    height: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: itemProfile(snapshot.data!.pugs, 'Pugs'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: InkWell(
                            child: itemProfile(
                                snapshot.data!.followers, 'Abonnés'),
                            onTap: () {
                              navigateTo(
                                  context,
                                  FollowersView.withName(
                                    userSearched: username,
                                  ));
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: InkWell(
                            child: itemProfile(
                                snapshot.data!.following, 'Abonnement'),
                            onTap: () {
                              navigateTo(
                                  context,
                                  FollowingView.withName(
                                      userSearched: username));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              (widget.username == "")
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                            style: BaseButtonSize(150, 30,
                                isFollowing ? Colors.transparent : APPCOLOR6),
                            onPressed: () async {
                              final result = await unFollowOrFollowUser(
                                  username, isFollowing);
                              if (result.code == SUCCESS_CODE) {
                                isFollowing = !isFollowing;
                                await fetchData();
                                setState(() {});
                              }
                            },
                            child: Text(textButton,
                                style: const TextStyle(color: Colors.white))),
                        IgnorePointer(
                            ignoring: (username == "lucie"),
                            child: OutlinedButton(
                                style:
                                    BaseButtonSize(150, 30, Colors.transparent),
                                onPressed: () {
                                  navigateTo(
                                      context,
                                      Chat.withUsername(
                                          receiverUsername: username));
                                },
                                child: const Text("Message",
                                    style: TextStyle(color: Colors.white)))),
                      ],
                    )
            ],
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const Center(
            child: Text("Aucune donnée"),
          );
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: APPCOLOR,
          ));
        }
      },
    );
  }

  Widget imageItemBuffer(PugModel model) {
    return InkWell(
      child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: FadeInImage.assetNetwork(
            image: model.imageURL,
            fit: BoxFit.fitWidth,
            placeholder: "asset/images/empty.png",
          )),
      onTap: () {
        if (widget.username == "") {
          navigateTo(context, Pug.withPugModel(model: model));
        } else {
          navigateTo(
              context,
              Pug.withPugModelFromOtherUser(
                  model: model, username: widget.username));
        }
      },
    );
  }

  Widget newProfileContent() {
    return FutureBuilder(
      future: _response,
      builder: (context, AsyncSnapshot<UserPugResponse> snapshot) {
        if (snapshot.hasData) {
          list = snapshot.data!.pugs;
          return Container(
            child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  return imageItemBuffer(list[index]);
                }),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const Center(
            child: Text(""),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text(""),
          );
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: APPCOLOR,
          ));
        }
      },
    );
  }

  Future<void> refreshData() async {
    if (widget.username == "") {
      _userResponse = getUserInfo();

      _response = getAllPugsFromUser();
    } else {
      _userResponse = getUserInfo();

      _response = getAllPugsFromUser();
    }
    _refreshController.refreshCompleted();
    scrollController.animateTo(200,
        duration: Duration(milliseconds: 1000), curve: Curves.ease);
    setState(() {});
  }

  void showMyDialogBlock(String username) {
    showDialog(
        context: context,
        builder: (context) => Center(
            child: AlertDialog(
              title: Text("Bloquage utilisateur"),
              content: Text("Vous vous appretez à bloquer "+username),
              actions: [
                ElevatedButton(
                  style: BaseButtonRoundedColor(60, 40, APPCOLOR),
                  onPressed: () async {
                    final result = await blockUser(username);
                    if (result.code == SUCCESS_CODE) {
                      showSnackBar(context, result.message);
                      Navigator.pop(context);
                      navigateWithNamePop(context, const Actuality().routeName);
                    }
                  },
                  child: const Text("Confirmer"),
                ),
                ElevatedButton(
                    style: BaseButtonRoundedColor(60, 40, APPCOLOR),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Annuler"))
              ],
            )));
  }

  showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      child: const Text(
                        "Signaler",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )),
                InkWell(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      child: const Text(
                        "Bloquer l'utilisateur",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )),InkWell(
                    onTap: () {Navigator.pop(context);},
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      child: const Text(
                        "Fermer",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )),
              ],
            ));
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
            automaticallyImplyLeading: hasBackButton,
            title: const Text("Profile"),
            backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
            actions: [
              IconButton(
                  onPressed: () => navigateTo(context, const Setting()),
                  icon: const Icon(Icons.settings_rounded)),
              IconButton(
                  onPressed: () => showBottomSheet(),
                  icon: Icon(Icons.more_vert)),
            ],
          ),
          body: Container(
            child: content(),
            decoration: BoxCircular(notifier),
          ),
        );
      },
    );
  }

  Widget content() {
    String pathImage = notifier.isDark
        ? "asset/images/logo-header-dark.png"
        : "asset/images/logo-header-light.png";

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: refreshData,
      child: CustomScrollView(controller: scrollController, slivers: [
        SliverAppBar(
          expandedHeight: 150,
          automaticallyImplyLeading: false,
          backgroundColor: notifier.isDark ? Colors.black : Colors.transparent,
          pinned: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              pathImage,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        SliverFillRemaining(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  child: profileHeader(),
                  width: getPhoneWidth(context),
                  height: 250,
                ),
                newProfileContent()
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
