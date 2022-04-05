
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Setting extends StatefulWidget {

  final routeName = 'setting';

  const Setting({Key? key}) : super(key: key);

  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.black,

        body:  Text('SplashScreen')

    );
  }
}
