import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/functions/validate_url.dart';
import 'package:mypug/components/pug/api.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/components/pug/web_view_screen.dart';
import 'package:mypug/components/shareitem/shareitem.dart';
import 'package:mypug/features/actuality/actuality.dart';
import 'package:mypug/features/comment/pugcomments.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:simple_shadow/simple_shadow.dart';
import '../../features/following/api.dart';
import '../../models/CommentModel.dart';
import '../../response/followerresponse.dart';
import '../../service/themenotifier.dart';

class PugItem extends StatefulWidget {
  final routeName = '/pugitem';
  final PugModel model;
  final String currentUsername;
  final bool fromProfile;
  final bool onShare;
  final bool profileView;
  VoidCallback? refreshCb;

  PugItem(
      {Key? key,
      required this.model,
      required this.currentUsername,
      this.onShare = false,
      this.profileView = false,
      this.fromProfile = false,
      this.refreshCb})
      : super(key: key);

  PugItem.fromProfile(
      {Key? key,
      required this.model,
      required this.currentUsername,
      this.fromProfile = true,
      this.profileView = false,
      this.onShare = false,
      this.refreshCb})
      : super(key: key);

  PugItem.onShare(
      {Key? key,
      required this.model,
      required this.currentUsername,
      this.fromProfile = false,
      this.profileView = false,
      this.onShare = true,
      this.refreshCb})
      : super(key: key);

  @override
  PugItemState createState() => PugItemState();
}

class PugItemState extends State<PugItem> {
  late String imageURL;
  late String imageTitle;
  late String imageDescription;
  late int imageLike;
  late List<Offset> points = [];
  TextEditingController textEditingController = TextEditingController();

  late CommentModel comment;
  late bool isLiked;

  bool isExpanded = false;
  bool isVisible = false;
  late bool isDarkMode;
  late double screenWidth = 0;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      maxImgHeight = MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.bottom -
          Scaffold.of(context).appBarMaxHeight!.toDouble();
      setState(() {});
    });
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = getPhoneWidth(context) > MAX_SCREEN_WIDTH
          ? MAX_SCREEN_WIDTH
          : getPhoneWidth(context);
    });
    super.initState();
    imageURL = widget.model.imageURL;
    imageTitle = widget.model.imageTitle!;
    imageDescription = widget.model.imageDescription;
    imageLike = widget.model.like;
    isLiked = widget.model.isLiked;

    if (widget.model.comments.isNotEmpty) {
      comment = widget.model.comments.last;
    }
    points.clear();
    for (var element in widget.model.details!) {
      points.add(
          Offset(element.positionX.toDouble(), element.positionY.toDouble()));
    }
  }

  Widget _typer(String text, isVisible) {
    return Container(
        child: AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: text.isNotEmpty
          ? Center(
              child: InkWell(
                  onTap: () {
                    if (!isValidUrl(text)) {
                      return;
                    }
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => WebViewScreen(url: text),
                    ));
                  },
                  child: Image.asset(
                    "asset/images/blur.png",
                    width: 25,
                    height: 25,
                  )
                  // InstagramMention(text: text, color: APP_COMMENT_COLOR)
                  ))
          : const SizedBox(
              width: 0,
            ),
    ));
  }

  double remap(double value, double fromLow, double fromHigh, double toLow,
      double toHigh) {
    final rangeFrom = fromHigh - fromLow;
    final rangeTo = toHigh - toLow;
    final scaled = (value - fromLow) / rangeFrom;
    return toLow + (scaled * rangeTo);
  }

  Widget imageContent() {
    //TODO:
    // Future.delayed(const Duration(milliseconds: 0)).then((value) {
    //   setState(() {});
    // });
    // print("llllllllllllllllllll: $navBarHeight");
    return Container(
        decoration: const BoxDecoration(),
        height: widget.onShare
            ? (widget.model.height > 200)
                ? 400
                : 300
            : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: false
                  ? MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.bottom -
                      Scaffold.of(context).appBarMaxHeight!.toDouble() -
                      navBarHeight
                  : MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.bottom -
                      Scaffold.of(context).appBarMaxHeight!.toDouble()),
          child: GestureDetector(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: widget.profileView
                          ? Image.network(
                              widget.model.imageURL,
                              fit: BoxFit.cover,
                            )
                          : ExtendedImage.network(
                              widget.model.imageURL,
                              fit: BoxFit.cover,
                              cache: true,
                              retries: 3,
                              timeRetry: const Duration(milliseconds: 100),
                            ),
                    ),
                    widget.profileView
                        ? Container(
                            color: Colors.black,
                            height: navBarHeight,
                            width: double.infinity,
                          )
                        : const SizedBox()
                  ],
                ),
                Column(children: [
                  widget.fromProfile
                      ? const SizedBox(
                          width: 0,
                          height: 0,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                !widget.onShare
                                    ? renderProfilePicture(
                                        widget.model.author.profilePicture,
                                        widget.model.author.profilePicture
                                            .isNotEmpty,
                                        40)
                                    : const SizedBox(width: 0),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    navigateTo(
                                        context,
                                        Profile.fromUsername(
                                            username:
                                                widget.model.author.username));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey.shade300
                                            .withOpacity(0.6)),
                                    child: Text(widget.model.author.username,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        )),
                                  ),
                                )
                              ],
                            ),
                            widget.fromProfile
                                ? const SizedBox(
                                    width: 0,
                                    height: 0,
                                  )
                                : IconButton(
                                    onPressed: () => showBottomSheetSignal(
                                        context,
                                        widget.model.author.username,
                                        widget.model.id,
                                        widget.refreshCb),
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 30,
                                    ))
                          ],
                        )
                ]),
                Stack(children: [
                  ...points
                      .asMap()
                      .map((i, e) => MapEntry(
                          i,
                          Positioned(
                            left: (remap(e.dx, 0, 1, 0, screenWidth - 29)),
                            top: remap(e.dy, 0, 0.99, 0, maxImgHeight - 35),
                            child: Wrap(
                                direction: Axis.vertical,
                                spacing: 1,
                                children: [
                                  _typer(
                                      widget.model.details![i].text, isVisible),
                                ]),
                          )))
                      .values
                      .toList()
                ]),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 90, right: 10),
                      child: imageInformationColumn(
                          imageTitle, widget.model.comments),
                    )),
              ],
            ),
            onDoubleTap: () async {
              if (!isLiked) {
                final result = await likeOrUnlikePug(
                    widget.model.id, widget.model.author.username, true);
                if (result.code == SUCCESS_CODE) {
                  imageLike += 1;
                  isLiked = !isLiked;

                  setState(() {});
                }
              }
            },
            onTap: () {
              if (widget.onShare) {
                navigateTo(
                    context,
                    Pug.withPugModelFromOtherUser(
                        model: widget.model,
                        username: widget.model.author.username));
              } else {
                isVisible = !isVisible;
                setState(() {});
              }
            },
          ),
        ));
  }

  Widget imageInformation(String title, list) {
    return Container(
      height: 75,
      decoration: widget.onShare ? const BoxDecoration(color: APPCOLOR5) : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        widget.onShare
            ? const SizedBox(
                height: 5,
                width: 0,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Text(
                      widget.model.numberOfComments.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 30,
                    child: Text(
                      imageLike > 1000 ? "999+" : imageLike.toString(),
                      style: TextStyle(
                          color: APPCOLOR,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            imageCommentaire(list),
            widget.onShare
                ? const SizedBox(
                    height: 0,
                    width: 0,
                  )
                : Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            if (!isLiked) {
                              final result = await likeOrUnlikePug(
                                  widget.model.id,
                                  widget.model.author.username,
                                  true);
                              if (result.code == SUCCESS_CODE) {
                                imageLike += 1;
                                isLiked = !isLiked;
                              }
                            } else {
                              final result = await likeOrUnlikePug(
                                  widget.model.id,
                                  widget.model.author.username,
                                  false);
                              if (result.code == SUCCESS_CODE) {
                                imageLike -= 1;
                                isLiked = !isLiked;
                              }
                            }
                            setState(() {});
                          },
                          icon: (isLiked)
                              ? Icon(
                                  Icons.favorite,
                                  color: APPCOLOR,
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  color: APPCOLOR,
                                )),
                    ],
                  )
          ],
        )
      ]),
    );
  }

  Future<bool> cancelDissmiss() {
    return Future.value(false);
  }

  Widget imageInformationColumn(String title, list) {
    return Container(
      height: 150,
      child: Column(children: [
        Dismissible(
            key: Key(widget.model.id),
            background: Align(
              alignment: Alignment.center,
              child: Text(
                textAlign: TextAlign.center,
                imageLike > 1000 ? "999+" : imageLike.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) {
              return cancelDissmiss();
            },
            child: SimpleShadow(
              color: Colors.black,
              offset: const Offset(5, 7), // Default: Offset(2, 2)
              sigma: 2,
              child: IconButton(
                onPressed: () async {
                  if (!isLiked) {
                    final result = await likeOrUnlikePug(
                        widget.model.id, widget.model.author.username, true);
                    if (result.code == SUCCESS_CODE) {
                      imageLike += 1;
                      isLiked = !isLiked;
                    }
                  } else {
                    final result = await likeOrUnlikePug(
                        widget.model.id, widget.model.author.username, false);
                    if (result.code == SUCCESS_CODE) {
                      imageLike -= 1;
                      isLiked = !isLiked;
                    }
                  }
                  setState(() {});
                },
                icon: Image.asset("asset/images/PositifCoeur.png",
                    color: isLiked ? Colors.red : Colors.white),
              ),
            )),
        Dismissible(
          key: Key(widget.model.imageURL),
          confirmDismiss: (direction) {
            return cancelDissmiss();
          },
          background: Align(
            alignment: Alignment.center,
            child: Text(
              textAlign: TextAlign.center,
              widget.model.numberOfComments.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          child: SimpleShadow(
            color: Colors.black,
            offset: const Offset(5, 7), // Default: Offset(2, 2)
            sigma: 2,
            child: IconButton(
                onPressed: () async {
                  navigateTo(
                      context,
                      PugComments.withData(
                          pugId: widget.model.id,
                          username: widget.model.author.username,
                          description: widget.model.imageDescription));
                },
                icon: Image.asset("asset/images/PositifMessage.png",
                    width: 30, height: 30, color: Colors.white)),
          ),
        ),
        !widget.onShare
            ? SimpleShadow(
                color: Colors.black,
                offset: const Offset(5, 7), // Default: Offset(2, 2)
                sigma: 2,
                child: GestureDetector(
                    onTap: () => showBottomSheetFollowing(
                        context, widget.currentUsername, widget.model),
                    child: Transform.rotate(
                      angle: -pi / 4,
                      child: const Image(
                        color: Colors.white,
                        image: AssetImage(
                          "asset/images/PositifEtiquette.png",
                        ),
                        width: 40,
                        height: 40,
                      ),
                    )),
              )
            : const SizedBox(
                width: 0,
                height: 0,
              ),
      ]),
    );
  }

  Widget imageCommentaire(List<CommentModel> list) {
    return Padding(
      padding: EdgeInsets.only(left: widget.onShare ? 10 : 0),
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                navigateTo(
                    context,
                    PugComments.withData(
                        pugId: widget.model.id,
                        username: widget.model.author.username,
                        description: widget.model.imageDescription));
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300.withOpacity(0.5)),
                child: Text(
                  "commentaires",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 19,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              )),
          SizedBox(
            height: widget.onShare ? 5 : 0,
          )
        ],
      ),
    );
  }

  Widget imageDetail(String detail) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        detail,
        style: TextStyle(color: isDarkMode ? Colors.black : Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        isDarkMode = notifier.isDark;
        return content(notifier);
      },
    );
  }

  Widget content(notifier) {
    if (!widget.profileView) {
      return Column(
        children: [
          imageContent(),
        ],
      );
    } else {
      return ListView(
        children: [
          // ListView(children: [],),
          imageContent(),
          widget.fromProfile
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: 7,
                  ),
                  child: Center(
                    child: ElevatedButton(
                        onPressed: () {
                          showMyDialogDelete("Suppréssion",
                              "Vous êtes sur le point de supprimer un pug");
                        },
                        child: const Text("Supprimer"),
                        style: BaseButtonRoundedColor(150, 40, APPCOLOR)),
                  ),
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                )
        ],
      );
    }
  }

  void showMyDialogDelete(String title, String text) {
    showDialog(
        context: context,
        builder: (context) => Center(
                child: AlertDialog(
              title: Text(title),
              content: Text(text),
              actions: [
                ElevatedButton(
                  style: BaseButtonRoundedColor(60, 40, APPCOLOR),
                  onPressed: () async {
                    final result = await deletePug(widget.model.id,
                        widget.model.author.username, widget.model.imageURL);
                    if (result.code == SUCCESS_CODE) {
                      showSnackBar(context, result.message);
                      Navigator.pop(context);
                      navigatePopUntilName(context, Profile().routeName);
                    }
                  },
                  child: const Text("Confirmer"),
                ),
                ElevatedButton(
                    style: BaseButtonRoundedColor(60, 40, APPCOLOR),
                    onPressed: () => Navigator.pop(context),
                    child: Text(sentence_cancel))
              ],
            )));
  }

  showBottomSheetFollowing(context, username, PugModel pugModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            child: FutureBuilder(
              future: getUserFollowings(username),
              builder: (context, AsyncSnapshot<FollowerResponse> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.users.length,
                    itemBuilder: (context, index) {
                      return ShareItem(
                          context: context,
                          user: snapshot.data!.users[index],
                          currentUsername: widget.currentUsername,
                          pugModel: pugModel);
                    },
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(
                      child: Text(
                    sentence_no_data,
                  ));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ));
      },
    );
  }
}
