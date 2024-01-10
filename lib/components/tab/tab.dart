import 'package:badges/badges.dart' as badges;
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
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // itemPadding: isSmallDevice
        //     ? const EdgeInsets.symmetric(vertical: 10, horizontal: 10)
        //     : const EdgeInsets.symmetric(vertical: 10),
        // marginR: isSmallDevice
        //     ? const EdgeInsets.symmetric(vertical: 10, horizontal: 20)
        //     : const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
        // paddingR: isSmallDevice
        //     ? const EdgeInsets.symmetric(vertical: 2)
        //     : const EdgeInsets.only(bottom: 5, top: 10),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.white70,
            label: "",
            icon: Image.asset(
              color: _selectedIndex == 0 ? Colors.black : Colors.white,
              "asset/images/PositifMaison.png",
              width: 30,
              height: 30,
            ),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white70,

            label: "",
            icon: Image.asset(
              "asset/images/PositifAmis.png",
              width: 30,
              height: 30,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomLeft,
              color: _selectedIndex == 1 ? Colors.black : Colors.white,
            ),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white70,

            label: "",
            icon: Image.asset(
              "asset/images/PositifPlus.png",
              width: 30,
              height: 30,
              color: _selectedIndex == 2 ? Colors.black : Colors.white,
            ),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white70,
            label: "",
            icon: (notificationNumber > 0)
                ? Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: badges.Badge(
                        badgeContent: Text(notificationNumber > 99
                            ? "99+"
                            : notificationNumber.toString()),
                        badgeColor: APPCOLOR6,
                        child: Image.asset(
                          "asset/images/PositifDiscussion.png",
                          width: 30,
                          height: 30,
                          color:
                              _selectedIndex == 3 ? Colors.black : Colors.white,
                        )),
                  )
                : Image.asset(
                    "asset/images/PositifDiscussion.png",
                    width: 30,
                    height: 30,
                    color: _selectedIndex == 3 ? Colors.black : Colors.white,
                  ),
          ),
          BottomNavigationBarItem(
              backgroundColor: Colors.white70,
              label: "",
              icon: Image.asset(
                "asset/images/PositifProfil.png",
                width: 30,
                height: 30,
                color: _selectedIndex == 4 ? Colors.black : Colors.white,
              )),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white70,

      ),
    );
  }
}
