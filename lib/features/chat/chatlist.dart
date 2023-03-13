import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/features/chat/chat.dart';
import 'package:mypug/models/ConversationModel.dart';
import 'package:mypug/models/userfactory.dart';
import 'package:mypug/response/conversationsresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../components/design/design.dart';
import '../../service/themenotifier.dart';
import 'api.dart';

class ChatList extends StatefulWidget {
  final routeName = '/chatlist';

  const ChatList({Key? key}) : super(key: key);

  @override
  ChatListState createState() => ChatListState();
}

class ChatListState extends State<ChatList> {
  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late String _username;
  late ThemeModel notifier;

  @override
  void initState() {
    getCurrentUsername().then((value) => _username = value);
    super.initState();
  }

  Future<void> onRefresh() async {
    setState(() {});
  }

  Widget itemChat(ConversationModel model) {
    UserFactory receiverUser = model.membersInfos
        .firstWhere((element) => element.username != _username);
    bool seen = !model.seen.contains(receiverUser);
    return InkWell(
      onTap: () =>
          navigateTo(context, Chat.withUsername(receiverUser: receiverUser)),
      child: ListTile(
        leading: receiverUser.profilePicture.isNotEmpty
            ? ClipRRect(
                child: Image.network(
                  receiverUser.profilePicture,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(100))
            : const Image(
                image: AssetImage(
                  'asset/images/user.png',
                ),
                width: 40,
                height: 40,
              ),
        trailing: seen
            ? Icon(
                Icons.send,
                color: APPCOLOR,
              )
            : Badge(
                badgeContent: Text("1"),
                badgeColor: APPCOLOR6,
                child: Icon(
                  Icons.send,
                  color: APPCOLOR,
                )),
        title: Text(
          receiverUser.username,
          style: TextStyle(
              fontSize: 17,
              color: notifier.isDark ? Colors.black : Colors.black),
        ),
        subtitle: Text(
          (model.chat.isEmpty
              ? ""
              : model.chat.first.type == "text"
                  ? model.chat.first.content
                  : "A partagé un pug"),
          style:
              TextStyle(color: notifier.isDark ? Colors.black : Colors.black),
        ),
      ),
    );
  }

  sortChatList(List<ConversationModel> list) {
    list.sort((a, b) {
      if (b.chat.isEmpty || a.chat.isEmpty) return 1;
      return a.chat.last.time.compareTo(b.chat.last.time) * -1;
    });
    return list;
  }

  Widget content() {
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: FutureBuilder(
          future: getUserConversations(),
          builder: (context, AsyncSnapshot<ConversationsResponse> snapshot) {
            if (snapshot.hasData) {
              List<ConversationModel> result =
                  sortChatList(snapshot.data!.conversations);
              if (snapshot.data!.conversations.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.conversations.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 5, left: 6, right: 6),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20)),
                        child: itemChat(result[index]),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("Aucune Conversation"),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loaderImage();
            }
            return const Center(
              child: Text("Aucune Conversation"),
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text("Conversations"),
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
