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
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late Future<ConversationsResponse> _response;
  late int notification = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const ActualityAll(),
    const Actuality(),
    const CreatePug(),
    const ChatList(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    fetchData();
    setState(() {
      _selectedIndex = index;
    });
  }

  fetchData() async {
    notification = 0;
    _response = getUserConversations();
    var username = await getCurrentUsername();
    _response.then((value) => {
          value.conversations.forEach((element) {
            if (!element.seen.contains(username)) {
              notification += 1;
            }
            ;
          }),
          setState(() {})
        });
  }

  void initState() {
    fetchData();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: DotNavigationBar(
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
            icon: (notification > 0)
                ? Badge(
                    badgeContent: Text(notification.toString()),
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
