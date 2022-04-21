/// Flutter code sample for BottomNavigationBar


import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/actuality/actuality.dart';
import 'package:mypug/features/chat/chatlist.dart';
import 'package:mypug/features/create/create.dart';
import 'package:mypug/features/profile/profile.dart';


/// This is the stateful widget that the main application instantiates.
class TabView extends StatefulWidget {
  final routeName = '/tabview';

  const TabView({Key? key}) : super(key: key);

  @override
  State<TabView> createState() => _TabViewState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _TabViewState extends State<TabView> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const Actuality(),
    const CreatePug(),
    const ChatList(),
    Profile(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Accueil',

            icon: const Icon(Icons.home),
            backgroundColor: APPCOLOR,

          ),
          BottomNavigationBarItem(
            label: 'Creer',

            icon: const Icon(Icons.add),
            backgroundColor: APPCOLOR,

          ),
          BottomNavigationBarItem(
            label: 'Message',

            icon: const Icon(Icons.messenger),
            backgroundColor: APPCOLOR,

          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: const Icon(Icons.account_circle),
            backgroundColor: APPCOLOR,

          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black54,
        backgroundColor: APPCOLOR,
        unselectedItemColor: Colors.white70,
        onTap: _onItemTapped,
      ),
    );
  }
}
