
import 'dart:convert';
import 'package:mypug/service/themenotifier.dart';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
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
    Navigator.pushReplacementNamed(context, '/signin' );
  }
  Widget itemData(String data){
    return Padding(padding: EdgeInsets.all(8), child:  Container(
      width: 300,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: APPCOLOR, width: 2)
      ), child:  Text(data, textAlign: TextAlign.center,),),);
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context,ThemeModel themeNotifier, child) {
        print(themeNotifier.isDark);
      return Scaffold(

          appBar: AppBar(

              backgroundColor: APPCOLOR,
              actions: [
                IconButton(
                    icon: Icon(themeNotifier.isDark
                        ? Icons.nightlight_round
                        : Icons.wb_sunny),
                    onPressed: () {
                      themeNotifier.isDark
                          ? themeNotifier.isDark = false
                          : themeNotifier.isDark = true;
                    })
              ],
          ),

          body: Center(
              child : FutureBuilder(
                future: getUserData(),
                builder: (context, snapshot) {

                  if(snapshot.hasData){
                    final data = snapshot.data as Map;
                    return  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      const Image( image : AssetImage('asset/images/user.png',), width: 100, height: 100,),
                      itemData(data['username']),
                      itemData(data['phoneNumber']),
                      itemData(data['email']),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child:                       ElevatedButton( style : BaseButtonRoundedColor(60, 40, APPCOLOR),onPressed: () => disconnectUser(), child: Text("Deconnexion"))
                          ),
                        )

                    ],);

                  }
                  else{
                    return Text("No data");
                  }
                },)
          )
      );

    },);

  }
}

