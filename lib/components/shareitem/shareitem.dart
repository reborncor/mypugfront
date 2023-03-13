
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/models/MessageModel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../features/profile/profile.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ShareItem extends StatefulWidget {
  final routeName = '/shareitem';
  final UserSearchModel user;
  final String currentUsername;
  final PugModel pugModel;

  const ShareItem({
    Key? key,
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
                  setState(() {})
                }
            });
  }

  sharePug() {
    final messageSent = MessageModel(
        time: "",
        content: widget.pugModel.toJson(),
        senderUsername: widget.currentUsername,
        receiverUsername: widget.user.username,
        type: 'pug',
        id: "");
    socket.emit("message", messageSent.toJson());
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
              leading: renderProfilePicture(widget.user.profilePicture, widget.user.profilePicture.isNotEmpty, 40),
              title: Text(
                widget.user.username,
                style: TextStyle(
                    color: this.notfier.isDark ? Colors.white : Colors.black),
              ),
              trailing: OutlinedButton(
                child: Text(text, style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  sharePug();
                },
              )),
        );
      },
    );
  }
}
