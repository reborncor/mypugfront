import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/followeritem/api.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/features/actuality/actuality.dart';
import 'package:mypug/features/chat/chat.dart';
import 'package:mypug/features/follower/follower.dart';
import 'package:mypug/features/following/following.dart';
import 'package:mypug/features/profile/api.dart';
import 'package:mypug/features/setting/setting.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/models/userfactory.dart';
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
  late bool isFollowing = false;
  late ThemeModel notifier;
  late String description = "";
  late TextEditingController descriptionController = TextEditingController();
  late String formerDescription;
  bool isModificated = false;
  late String formerProfilePicture;
  final RefreshController _refreshController = RefreshController();
  final RefreshController _refreshController2 = RefreshController();
  late ScrollController scrollController =
      ScrollController(initialScrollOffset: 200);
  late bool hasBackButton = false;
  final ImagePicker _picker = ImagePicker();
  File? imageFile;
  bool onUpdateMode = false;
  late bool isSmallDevice = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      isSmallDevice = MediaQuery.of(context).size.width < 355;
    });
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

  _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      imageFile = File(image!.path);
    });
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
          if (snapshot.data!.code == BLOCKED_CODE)
            return SizedBox(
              width: 0,
              height: 0,
            );
          username = snapshot.data!.username;
          formerProfilePicture = snapshot.data!.profilePicture;
          formerDescription = snapshot.data!.description!;
          isFollowing = snapshot.data!.isFollowing ?? false;
          String textButton = isFollowing ? "Se désabonner" : "S'abonner";
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SizedBox(
                          height: isSmallDevice ? 75 : 150,
                          width: isSmallDevice ? 75 : 120,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 100,
                            child: snapshot.data!.profilePicture.isNotEmpty
                                ? ClipRRect(
                                    child: imageFile == null
                                        ? ExtendedImage.network(
                                            snapshot.data!.profilePicture,
                                            height: isSmallDevice ? 75 : 100,
                                            width: isSmallDevice ? 75 : 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(imageFile!,
                                            height: isSmallDevice ? 75 : 100,
                                            width: isSmallDevice ? 75 : 100,
                                            fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(100))
                                : imageFile == null
                                    ? const Image(
                                        fit: BoxFit.contain,
                                        image:
                                            AssetImage('asset/images/user.png'),
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.file(imageFile!,
                                            height: isSmallDevice ? 75 : 100,
                                            width: isSmallDevice ? 75 : 100,
                                            fit: BoxFit.cover),
                                      ),
                          ),
                        ),
                        Visibility(
                            visible: onUpdateMode,
                            child: InkWell(
                              onTap: _imgFromGallery,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(color: APPCOLOR),
                                  child: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ))
                      ],
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
              Padding(
                padding: const EdgeInsets.only(
                    left: 40, right: 40, top: 5, bottom: 5),
                child: onUpdateMode
                    ? TextField(
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              description = descriptionController.text;
                              isModificated = true;
                              onUpdateMode = !onUpdateMode;
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {});
                            },
                            iconSize: 20,
                            color: APPCOLOR,
                            icon: Icon(Icons.check),
                          ),
                          focusedBorder: setOutlineBorder(0.0, 20.0),
                          enabledBorder: setOutlineBorder(0.0, 20.0),
                          border: setOutlineBorder(1.5, 20.0),
                        ),
                        controller: descriptionController,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        maxLength: 180,
                      )
                    : Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          description != ""
                              ? description
                              : snapshot.data!.description!,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                notifier.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
              ),
              SizedBox(
                height: 10,
              ),
              (widget.username == "")
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: BaseButtonSize(250, 30, APPCOLOR),
                          onPressed: () {
                            onUpdateMode = !onUpdateMode;
                            setState(() {});
                          },
                          child: Text(onUpdateMode ? "Fermer" : "Modifier",
                              style: const TextStyle(color: Colors.white)),
                        ),
                        (isModificated)
                            ? Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: IconButton(
                                    onPressed: () async {
                                      final result = await updateUserInfo(
                                          description,
                                          snapshot.data!.profilePicture,
                                          imageFile != null,
                                          imageFile,
                                          formerProfilePicture);
                                      if (result.code == SUCCESS_CODE) {
                                        refreshUserInfo();
                                        saveUserProfilePicture(
                                            result.profilePicture);
                                        showToast(context,
                                            "modification utilisateur effectuée");
                                        setState(() {});
                                      }
                                    },
                                    iconSize: 30,
                                    color: APPCOLOR,
                                    icon: Icon(Icons.check)),
                              )
                            : const SizedBox(
                                width: 0,
                              )
                      ],
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
                                          receiverUser: UserFactory(
                                              username: username,
                                              profilePicture:
                                                  snapshot.data!.profilePicture,
                                              id: "")));
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
        child: ExtendedImage.network(
          model.imageURL,
          fit: BoxFit.cover,
          cache: true,
          retries: 3,
          timeRetry: const Duration(milliseconds: 100),


        ),
      ),
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
          if (snapshot.data!.code == BLOCKED_CODE) return Text("Compte bloqué");
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

  refreshUserInfo() {
    imageFile = null;
    description = "";
    isModificated = false;
    _userResponse = getUserInfo();
  }

  Future<void> refreshData() async {
    if (widget.username == "") {
      refreshUserInfo();
      _response = getAllPugsFromUser();
      hasBackButton = false;
    } else {
      _userResponse = getUserInfoFromUsername(widget.username);
      _response = getAllPugsFromUsername(widget.username);
      hasBackButton = true;
    }
    _refreshController.refreshCompleted();
    scrollController.animateTo(200,
        duration: Duration(milliseconds: 1000), curve: Curves.bounceOut);
    setState(() {});
  }

  void showMyDialogBlock(String username) {
    showDialog(
        context: context,
        builder: (context) => Center(
                child: AlertDialog(
              title: Text("Bloquage utilisateur"),
              content: Text("Vous vous appretez à bloquer " + username),
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
              (widget.username == "")
                  ? const SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : IconButton(
                      onPressed: () =>
                          showBottomSheetSignal(context, widget.username, ""),
                      icon: const Icon(Icons.more_vert)),
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

    return NestedScrollView(
      controller: scrollController,
      headerSliverBuilder: (context, innerBoxScrolled) => [
        SliverAppBar(
          collapsedHeight: 120,
          automaticallyImplyLeading: false,
          backgroundColor: notifier.isDark ? Colors.black : Colors.transparent,
          floating: true,
          pinned: false,
          stretch: true,
          forceElevated: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              pathImage,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ],
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: refreshData,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  child: profileHeader(),
                  width: getPhoneWidth(context),
                  height: onUpdateMode ? 700 : 350,
                ),
                newProfileContent()
              ],
            )),
      ),
    );
  }
}
