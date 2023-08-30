import 'package:badges/badges.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/actuality/actuality.dart';
import 'package:mypug/features/actualityall/actualityall.dart';
import 'package:mypug/features/chat/chatlist.dart';
import 'package:mypug/features/create/create.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/util/util.dart';

import '../../features/chat/api.dart';
import '../../response/conversationsresponse.dart';

class TabView extends StatefulWidget {
  final routeName = '/tabview';
  final int initialIndex;

  const TabView({Key? key, this.initialIndex = 0}) : super(key: key);

  const TabView.withIndex({Key? key, required this.initialIndex})
      : super(key: key);

  @override
  State<TabView> createState() => TabViewState();
}

class TabViewState extends State<TabView> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late Future<ConversationsResponse> _response;
  late int notification = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const ActualityAll(),
    const Actuality(),
    const CreatePug(),
    ChatList(),
    Profile(),
  ];

  updateBadge() {
    setState(() {});
  }

  Future<void> _onItemTapped(int index) async {
    await fetchData();
    setState(() {
      _selectedIndex = index;
    });
  }

  fetchData() async {
    notificationNumber = 0;
    _response = getUserConversations();
    var username = await getCurrentUsername();
    _response.then((value) => {
          value.conversations.forEach((element) {
            if (!element.seen.contains(username)) {
              notificationNumber += 1;
            }
          }),
          setState(() {})
        });
  }

  void initState() {
    fetchData();
    _selectedIndex = widget.initialIndex;
  }

  getItem() {
    if (_selectedIndex == 3) {
      return ChatList(
        onChatlistEvent: updateBadge,
      );
    }
    return _widgetOptions.elementAt(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallDevice = MediaQuery.of(context).size.width < 370 ||
        MediaQuery.of(context).devicePixelRatio < 2.7;
    return Scaffold(
      extendBody: true,
      body: Center(child: getItem()),
      bottomNavigationBar: DotNavigationBar(
        itemPadding: isSmallDevice
            ? const EdgeInsets.symmetric(vertical: 10, horizontal: 10)
            : const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        marginR: isSmallDevice
            ? const EdgeInsets.symmetric(vertical: 10, horizontal: 20)
            : const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        paddingR: isSmallDevice
            ? const EdgeInsets.symmetric(vertical: 2)
            : const EdgeInsets.only(bottom: 5, top: 10),
        items: <DotNavigationBarItem>[
          DotNavigationBarItem(
            icon: const Icon(Icons.home),
          ),
          DotNavigationBarItem(
            icon: Image.asset(
              "asset/images/acutalityall.png",
              width: 30,
              height: 30,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomLeft,
              color: Colors.white,
            ),
          ),
          DotNavigationBarItem(
            icon: const Icon(Icons.add),
          ),
          DotNavigationBarItem(
            icon: (notificationNumber > 0)
                ? Badge(
                    badgeContent: Text(notificationNumber > 99
                        ? "99+"
                        : notificationNumber.toString()),
                    badgeColor: APPCOLOR6,
                    child: const Icon(Icons.messenger),
                  )
                : const Icon(Icons.messenger),
          ),
          DotNavigationBarItem(
            icon: const Icon(Icons.account_circle),
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: APPCOLOR,
        selectedItemColor: Colors.white70,
        dotIndicatorColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
