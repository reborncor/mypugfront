import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/models/CommentModel.dart';
import 'package:mypug/response/commentresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../components/design/design.dart';
import '../../components/pug/api.dart';
import '../../service/themenotifier.dart';
import 'api.dart';

class PugComments extends StatefulWidget {
  final routeName = '/pugcomments';
  final String pugId;
  final String username;
  String description;

  PugComments(
      {Key? key, this.pugId = "", this.username = "", this.description = ""})
      : super(key: key);

  PugComments.withData(
      {Key? key,
      required this.pugId,
      required this.username,
      required this.description});

  @override
  PugCommentsState createState() => PugCommentsState();
}

class PugCommentsState extends State<PugComments> {
  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late String _username;
  late CommentModel comment;
  TextEditingController textEditingController = TextEditingController();
  late List<CommentModel> comments = [];
  late ThemeModel notifier;

  @override
  void initState() {
    getCurrentUsername().then((value) => _username = value);
    super.initState();
  }

  Widget itemComment(CommentModel model) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3, top: 3),
      child: Container(
          padding: const EdgeInsets.only(bottom: 3.0, top: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade100.withOpacity(0.6),
          ),
          child: InkWell(
              child: Row(
            children: [
              const Image(
                image: AssetImage(
                  'asset/images/user.png',
                ),
                width: 40,
                height: 40,
              ),
              Text(
                model.author,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: notifier.isDark ? Colors.black : Colors.black),
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: Text(
                  model.content,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                      fontSize: 18,
                      color: notifier.isDark ? Colors.black : Colors.black),
                ),
              )
            ],
          ))),
    );
  }

  Widget content() {
    return FutureBuilder(
      future: getPugComment(widget.pugId, widget.username),
      builder: (context, AsyncSnapshot<CommentResponse> snapshot) {
        if (snapshot.hasData) {
          log(snapshot.data!.comments.length.toString());
          comments = snapshot.data!.comments;
          log("Decription :" + widget.description);
          return Column(
            children: [
              (widget.description.isEmpty)
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(widget.description,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                    ),
              Expanded(
                  child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return itemComment(comments[index]);
                },
              ))
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

  Widget imageAddComment(String author, String pugId) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                    color: notifier.isDark ? Colors.white : Colors.black),
                controller: textEditingController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () async {
                        if (textEditingController.text.isNotEmpty) {
                          final result = await sendComment(
                              pugId, author, textEditingController.text);
                          if (result.code == SUCCESS_CODE) {
                            comment = CommentModel(
                                id: "",
                                author: _username,
                                content: textEditingController.text,
                                date: "");
                            comments.add(comment);
                            setState(() {});
                            textEditingController.clear();
                          }
                        }
                      },
                      icon: Icon(
                        Icons.send,
                        color: APPCOLOR,
                      )),
                  hintText: "Ajouter un commentaire",
                  hintStyle: TextStyle(
                      color: notifier.isDark ? Colors.white : Colors.black),
                  focusedBorder: setOutlineBorder(1.5, 20.0),
                  enabledBorder: setOutlineBorder(1.5, 20.0),
                  border: setOutlineBorder(1.5, 20.0),
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
          appBar: AppBar(
            title: Text("Commentaires"),
            backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
          ),
          body: Container(
            child: Column(
              children: [
                Expanded(child: content()),
                imageAddComment(widget.username, widget.pugId)
              ],
            ),
            decoration: BoxCircular(notifier),
          ));
    });
  }
}
