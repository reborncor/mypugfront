
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/util/util.dart';

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

  disconnectUser() async {
    await deleteData();
    Navigator.pushReplacementNamed(context, '/signin' );  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),

        body:  Column(children: [
          ElevatedButton(onPressed: () => disconnectUser(), child: Text("Deconnexion"))
        ],)

    );
  }
}

