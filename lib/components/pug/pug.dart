import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pugitem.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:provider/provider.dart';

import '../../features/setting/setting.dart';
import '../../service/themenotifier.dart';
import '../../util/util.dart';
import '../design/design.dart';

class Pug extends StatefulWidget {
  final routeName = '/pug';
  final PugModel? model;
  final String? username;


  final bool isOwner;

  const Pug(
      {Key? key, this.model, this.username, this.isOwner = false})
      : super(key: key);

  const Pug.withPugModel(
      {Key? key, required this.model, this.username, this.isOwner = true})
      : super(key: key);

  const Pug.withPugModelFromOtherUser(
      {Key? key, required this.model, this.username, this.isOwner = false})
      : super(key: key);

  @override
  PugState createState() => PugState();
}

class PugState extends State<Pug> {
  late String imageURL;
  late String imageTitle;
  late String imageDescription;
  late int imageLike;
  late ThemeModel notifier;
  List<Offset> points = [];

  bool isExpanded = false;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    imageURL = widget.model!.imageURL;
    imageTitle = widget.model!.imageTitle!;
    imageDescription = widget.model!.imageDescription;
    imageLike = widget.model!.like;
    points.clear();
    for (var element in widget.model!.details!) {
      points.add(
          Offset(element.positionX.toDouble(), element.positionY.toDouble()));
    }
    ;


  }

  Widget imageInformation(String title, int like) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.favorite),
                label: Text(
                  like.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profil"),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                  onPressed: () => navigateTo(context, const Setting()),
                  icon: const Icon(Icons.settings_rounded))
            ],
          ),
          body: Container(
            decoration: BoxGradient(),
            child: Container(
              child: PugItem.fromProfile(

                currentUsername: widget.model!.author.username,
                model: widget.model!,
                fromProfile: widget.isOwner,
                profileView: true,
              ),
              decoration: BoxCircular(notifier),
            ),
          ),
        );
      },
    );
  }
}
