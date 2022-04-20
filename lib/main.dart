import 'package:flutter/material.dart';
import 'package:mypug/features/actuality/actuality.dart';
import 'package:mypug/features/auth/signin/signin.dart';
import 'package:mypug/features/auth/signup/signup.dart';
import 'package:mypug/features/chat/chatlist.dart';
import 'package:mypug/features/comment/pugcomments.dart';
import 'package:mypug/features/create/create.dart';
import 'package:mypug/features/search/search.dart';
import 'package:mypug/features/setting/setting.dart';
import 'package:mypug/features/splashscreen/splash_screen.dart';

import 'components/pug/pug.dart';
import 'components/tab/tab.dart';
import 'features/chat/chat.dart';
import 'features/profile/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      routes: {
        '/actuality': (context) => const Actuality(),
        '/create': (context) => const Create(),
        '/profile': (context) => Profile(),
        '/setting': (context) => const Setting(),
        '/tabview': (context) => const TabView(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/pug': (context) => const Pug(),
        '/search': (context) => const Search(),
        '/chatlist': (context) => const ChatList(),
        '/chat': (context) => Chat(),
        '/pugscomments': (context) => const PugComments(),






      },
      title: 'MyPUG',
    home: const SplashScreen(),
    );
  }
}
