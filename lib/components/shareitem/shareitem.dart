import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/models/MessageModel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../features/profile/profile.dart';
import '../design/design.dart';

class ShareItem extends StatefulWidget {
  final routeName = '/shareitem';
  final UserSearchModel user;
  final String currentUsername;
  final PugModel pugModel;
  final BuildContext context;

  const ShareItem({
    Key? key,
    required this.context,
    required this.user,
    required this.currentUsername,
    required this.pugModel,
  }) : super(key: key);

  @override
  ShareItemState createState() => ShareItemState();
}

class ShareItemState extends State<ShareItem> {
  String text = "Envoyer";
  bool notSend = true;
  bool isLoading = false;
  late ThemeModel notfier;
  late IO.Socket socket;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    socket = socketService.getSocket();
    socket.on(
        "messagesuccess",
        (data) => {
              if (data == '0_${widget.user.username}')
                {
                  notSend = false,
                  text = notSend ? "Envoyer" : "Envoyé",
                  if (mounted)
                    {
                      isLoading = false,
                      setState(() {}),
                      Navigator.pop(context),
                      if (widget.user.username == LUCIE)
                        {_showMyDialog(widget.context)}
                    }
                  else
                    {},
                }
            });
  }

  sharePug() {
    isLoading = true;
    setState(() {});
    final messageSent = MessageModel(
        time: "",
        content: widget.pugModel.toJson(),
        senderUsername: widget.currentUsername,
        receiverUsername: widget.user.username,
        type: 'pug',
        id: "");
    socket.emit("message", messageSent.toJson());
  }

  Future<void> _showMyDialog(context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Done')),
            backgroundColor: APP_COMMENT_COLOR,
            content: const SingleChildScrollView(
              child: Text('Vous ne pouvez pas envoyer de pug à Lucie'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Fait'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        notfier = notifier;
        return InkWell(
          onTap: () => navigateTo(
              context, Profile.fromUsername(username: widget.user.username)),
          child: ListTile(
              leading: renderProfilePicture(widget.user.profilePicture,
                  widget.user.profilePicture.isNotEmpty, 40),
              title: Text(
                widget.user.username,
                style: TextStyle(
                    color: this.notfier.isDark ? Colors.white : Colors.black),
              ),
              trailing: isLoading
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      child: Text(text,
                          style: const TextStyle(color: Colors.white)),
                      onPressed: () {
                        widget.user.username == LUCIE
                            ? _showMyDialog(context)
                            : sharePug();
                      },
                    )),
        );
      },
    );
  }
}
