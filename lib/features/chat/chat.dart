import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pugitem.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/models/userfactory.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../components/design/design.dart';
import '../../models/MessageModel.dart';
import '../../response/conversationresponse.dart';
import '../../response/oldmessageresponse.dart';
import '../../util/util.dart';
import 'api.dart';

class Chat extends StatefulWidget {
  final routeName = '/chat';
  UserFactory receiverUser = UserFactory.NullValue();
  bool seen = true;

  Chat({Key? key}) : super(key: key);

  Chat.withUsername({Key? key, required this.receiverUser, required this.seen})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late IO.Socket socket;
  late ConversationResponse response;
  late OldMessageResponse responseOldMessage;
  List<MessageModel> messages = [];
  TextEditingController messageToSend = TextEditingController();
  late String username;
  late String userProfilePicture;
  StreamController streamController = StreamController();
  late ScrollController scrollController;
  late MessageModel messageSent = MessageModel(
      id: "id",
      senderUsername: "senderUsername",
      type: "text",
      receiverUsername: "receiverUsername",
      content: "content",
      time: "time");
  late MessageModel newMessage;
  late int startInd;
  late int endInd;
  late ThemeModel themeNotifier;
  bool isSeen = false;
  late AppBar appBar;

  scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      fetchOldMessage();
      setState(() {});
    }
    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      sendMessageSeen();
      setState(() {
        log("reach the Bottom");
      });
    }
  }

  goUp() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    } else {}
  }

  goDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  initState() {
    startInd = 10;
    endInd = startInd + 10;
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
    fetchUsername();
    fetchData();

    init();

    super.initState();
  }

  fetchUsername() async {
    await getUserData().then((value) {
      username = value["username"];
      userProfilePicture = value["profilePicture"];
    });
  }

  fetchOldMessage() async {
    var data = await getUserMessagePageable(
        widget.receiverUser.username, startInd, endInd);
    responseOldMessage = data;
    messages.addAll(responseOldMessage.oldmessages);
    startInd += 10;
    endInd += 10;
    streamController.add("event");
  }

  fetchData() async {
    var data = await getUserConversation(widget.receiverUser.username);
    response = data;
    log("TEST :" + response.conversation.toString());
    messages = response.conversation.chat;
    streamController.add(data);
    sendMessageSeen();
  }

  addMessageToList(MessageModel messageModel) {
    messages.insert(0, messageModel);
    streamController.add("ok");
  }

  @override
  void dispose() {
    super.dispose();
  }

  init() {
    socket = socketService.getSocket();
    socket.on(
        "messagesuccess",
        (data) => {
              if (data == '0_${widget.receiverUser.username}')
                {
                  addMessageToList(messageSent),
                }
            });

    socket.on("seenCallback", (data) => {});

    socket.on(
        "instantmessage",
        (data) => {
              if (!mounted) print("NOT MOUNTED"),
              newMessage = MessageModel.fromJsonData(data),
              addMessageToList(newMessage),
            });
  }

  sendMessage(String message) {
    if (message.trim().isNotEmpty && username != widget.receiverUser.username) {
      messageSent = MessageModel(
          time: "",
          content: message,
          senderUsername: username,
          receiverUsername: widget.receiverUser.username,
          type: 'text',
          id: "");
      socket.emit("message", messageSent.toJson());
    }
  }

  sendMessageSeen() {
    isSeen = true;
    socket.emit("seenConversation", {
      "senderUsername": username,
      "conversationId": response.conversation.id
    });
  }

  Widget messageEditor() {
    return Row(
      children: <Widget>[
        Expanded(
            child: TextField(
          maxLines: null,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          controller: messageToSend,
          decoration: InputDecoration(
            suffixIcon: IconButton(
                onPressed: () {
                  sendMessage(messageToSend.text);
                  messageToSend.clear();
                },
                icon: Icon(Icons.send, color: APPCOLOR)),
            enabledBorder: setOutlineBorder(
              1.5,
              10.0,
            ),
            focusedBorder: setOutlineBorder(
              1.5,
              10.0,
            ),
            border: setOutlineBorder(
              1.5,
              10.0,
            ),
          ),
          onTap: () {
            goUp();
          },
        )),
      ],
    );
  }

  Widget itemMessage(MessageModel messageModel) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Align(
            alignment: (messageModel.senderUsername == username)
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 300),
              child: (messageModel.senderUsername != username)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          child: renderProfilePicture(
                              widget.receiverUser.profilePicture,
                              widget.receiverUser.profilePicture.isNotEmpty,
                              40),
                          onTap: () {
                            navigateTo(
                                context,
                                Profile.fromUsername(
                                    username: widget.receiverUser.username));
                          },
                        ),
                        Flexible(
                            child: messageModel.type == 'text'
                                ? Card(
                                    color: (messageModel.senderUsername ==
                                            username)
                                        ? Colors.indigo[50]
                                        : Colors.white70,
                                    child: Padding(
                                      child: Text(
                                        messageModel.content,
                                        style: TextStyle(
                                            color: themeNotifier.isDark
                                                ? Colors.black
                                                : Colors.black),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  )
                                : PugItem.onShare(
                                    model: messageModel.content,
                                    currentUsername: username))
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Flexible(
                          child: messageModel.type == 'text'
                              ? Card(
                                  color:
                                      (messageModel.senderUsername == username)
                                          ? Colors.indigo[50]
                                          : Colors.white70,
                                  child: Padding(
                                    child: Text(
                                      messageModel.content,
                                      style: TextStyle(
                                          color: themeNotifier.isDark
                                              ? Colors.black
                                              : Colors.black),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                )
                              : PugItem.onShare(
                                  model: messageModel.content,
                                  currentUsername: username),
                        ),
                        renderProfilePicture(userProfilePicture,
                            userProfilePicture.isNotEmpty, 40),
                      ],
                    ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.themeNotifier = notifier;
        return WillPopScope(
          onWillPop: () async {
            if (isSeen &&
                messages.isNotEmpty &&
                messages.first.senderUsername == widget.receiverUser.username &&
                notificationNumber > 0) {
              notificationNumber -= 1;
              setState(() {
                notificationNumber;
              });
            }
            Navigator.pop(context, notificationNumber);
            return true;
          },
          child: Scaffold(
              appBar: appBar = AppBar(
                backgroundColor: Colors.black,
                title: Text(widget.receiverUser.username),
              ),
              body: Container(
                child: StreamBuilder(
                  stream: streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            controller: scrollController,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return itemMessage(messages[index]);
                            },
                          ),
                        ),
                        Expanded(flex: 0, child: messageEditor())
                      ]);
                    } else {
                      return Center(
                          child: CircularProgressIndicator(
                        color: APPCOLOR,
                      ));
                    }
                  },
                ),
                decoration: BoxCircular(themeNotifier),
              )),
        );
      },
    );
  }
}
