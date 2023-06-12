import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mypug/features/actuality/actuality.dart';
import 'package:mypug/features/actualityall/actualityall.dart';
import 'package:mypug/features/auth/signin/signin.dart';
import 'package:mypug/features/auth/signup/signup.dart';
import 'package:mypug/features/chat/chatlist.dart';
import 'package:mypug/features/comment/pugcomments.dart';
import 'package:mypug/features/competition/competition.dart';
import 'package:mypug/features/competition/competitionpayment.dart';
import 'package:mypug/features/create/create.dart';
import 'package:mypug/features/follower/follower.dart';
import 'package:mypug/features/following/following.dart';
import 'package:mypug/features/search/search.dart';
import 'package:mypug/features/setting/setting.dart';
import 'package:mypug/features/splashscreen/splash_screen.dart';
import 'package:mypug/features/userblocked/userblocked.dart';
import 'package:mypug/service/HttpService.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:provider/provider.dart';

import 'components/pug/pug.dart';
import 'components/tab/tab.dart';
import 'features/chat/chat.dart';
import 'features/profile/profile.dart';

void main() {
  httpCheck();
  runApp(MyApp());
}

void httpCheck() {
  HttpOverrides.global = MyHttpOverrides();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
          return Align(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,

                  routes: {
                    '/actualityall': (context) => ActualityAll(),
                    '/actuality': (context) => Actuality(),
                    '/create': (context) => CreatePug(),
                    '/profile': (context) => Profile(),
                    '/setting': (context) => Setting(),
                    '/tabview': (context) => TabView(),
                    '/signin': (context) => SignIn(),
                    '/signup': (context) => SignUp(),
                    '/pug': (context) => Pug(),
                    '/search': (context) => Search(),
                    '/chatlist': (context) => ChatList(),
                    '/chat': (context) => Chat(),
                    '/pugscomments': (context) => PugComments(),
                    '/follower': (context) => FollowersView(),
                    '/following': (context) => FollowingView(),
                    '/usersblocked': (context) => UsersBlockedView(),
                    '/competition': (context) => Competition(),
                    '/competitionPayment': (context) => CompetitionPayment(),
                  },

                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    primaryColorDark: Colors.black,
                    primaryColor: Colors.black54,
                    scaffoldBackgroundColor: Colors.black54,
                    bottomSheetTheme: BottomSheetThemeData(
                      backgroundColor: Colors.black54,
                      modalBackgroundColor: Colors.black54,
                    ),
                  ),

                  // theme: ThemeData(
                  //   bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black54,modalBackgroundColor: Colors.black54,),
                  //   brightness: Brightness.dark,
                  //   primaryColorDark: Colors.black,
                  //   primaryColor: Colors.black54,
                  //   scaffoldBackgroundColor: Colors.black54,
                  // ),

                  // themeMode: themeNotifier.isDark ?  ThemeMode.dark : ThemeMode.light,

                  themeMode: ThemeMode.dark,

                  title: 'MyPUG',
                  home: const SplashScreen(),
                )),
          );
        },
      ),
    );
  }
}
