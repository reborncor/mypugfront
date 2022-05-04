import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mypug/features/actuality/actuality.dart';
import 'package:mypug/features/auth/signin/signin.dart';
import 'package:mypug/features/auth/signup/signup.dart';
import 'package:mypug/features/chat/chatlist.dart';
import 'package:mypug/features/comment/pugcomments.dart';
import 'package:mypug/features/create/create.dart';
import 'package:mypug/features/follower/follower.dart';
import 'package:mypug/features/following/following.dart';
import 'package:mypug/features/search/search.dart';
import 'package:mypug/features/setting/setting.dart';
import 'package:mypug/features/splashscreen/splash_screen.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:provider/provider.dart';

import 'components/pug/pug.dart';
import 'components/tab/tab.dart';
import 'features/chat/chat.dart';
import 'features/profile/profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder:(context, ThemeModel themeNotifier, child) {
          log(themeNotifier.isDark.toString());
        return MaterialApp(

          routes: {
            '/actuality': (context) =>  Actuality(),
            '/create': (context) =>  CreatePug(),
            '/profile': (context) => Profile(),
            '/setting': (context) =>  Setting(),
            '/tabview': (context) =>  TabView(),
            '/signin': (context) =>  SignIn(),
            '/signup': (context) =>  SignUp(),
            '/pug': (context) =>  Pug(),
            '/search': (context) =>  Search(),
            '/chatlist': (context) =>  ChatList(),
            '/chat': (context) => Chat(),
            '/pugscomments': (context) =>  PugComments(),
            '/follower': (context) =>  FollowersView(),
            '/following': (context) =>  FollowingView(),


          },



          darkTheme: ThemeData(
            // backgroundColor: Colors.red,
            brightness: Brightness.dark,
            primaryColorDark: Colors.black,
            primaryColor: Colors.black54,
            scaffoldBackgroundColor: Colors.black54

          ),


          // themeMode: ThemeMode.dark,
          // theme: themeNotifier.isDark ? ThemeData.dark(): ThemeData.light(),


          title: 'MyPUG',
          home: const SplashScreen(),
        );
      },
      ),
    );
  }
}
