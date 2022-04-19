/// Flutter code sample for BottomNavigationBar


import 'package:flutter/material.dart';
import 'package:mypug/features/actuality/actuality.dart';
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
    const Create(),
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
            backgroundColor: Colors.red[700],

          ),
          BottomNavigationBarItem(
            label: 'Creer',

            icon: const Icon(Icons.add),
            backgroundColor: Colors.red[700],

          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: const Icon(Icons.account_circle),
            backgroundColor: Colors.red[700],

          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black87,
        backgroundColor: Colors.red[700],
        unselectedItemColor: Colors.red[50],
        onTap: _onItemTapped,
      ),
    );
  }
}
