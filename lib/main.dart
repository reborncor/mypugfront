import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypug/components/editpug/editpug.dart';
import 'package:mypug/components/editpug/editpugsecond.dart';
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
import 'package:mypug/models/userfactory.dart';
import 'package:mypug/service/HttpService.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'components/pug/pug.dart';
import 'components/tab/tab.dart';
import 'features/chat/chat.dart';
import 'features/profile/profile.dart';
import 'firebase_options.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage event) async {
  var vibrator = await Vibration.hasVibrator();
  if (vibrator != null && vibrator && Platform.isIOS) {
    Vibration.vibrate();
  }
}

Future<void> main() async {
  await setUpEnv();
  httpCheck();
  runApp(MyApp());
}

void httpCheck() {
  HttpOverrides.global = MyHttpOverrides();
}

setUpEnv() async {
  await dotenv.load();
  STRIPE_KEY = dotenv.get('STRIPE_KEY', fallback: 'STRIPE_KEY N/A');
  Stripe.publishableKey = STRIPE_KEY;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  NOTIFICATION_TOKEN = (await _firebaseMessaging.getToken())!;

  await FlutterNotificationChannel.registerNotificationChannel(
    description: 'Basic notification',
    id: 'vibratenow',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'App notification',
    enableSound: true,
    enableVibration: true,
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
    print("message receveid");
    print(event.notification?.title);
  });

  FirebaseMessaging.onBackgroundMessage((firebaseMessagingBackgroundHandler));

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) async {
    print("message clicked");
    print(event.notification?.title);

    if (event.data['type'] == "message") {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => Chat.withUsername(
          receiverUser: UserFactory(
              id: "",
              username: event.data['sender_username'],
              profilePicture: event.data['sender_profilepicture']),
          seen: false,
        ),
      ));
    }
    if (event.data['type'] == "comment") {
          navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => PugComments.withData(
                  pugId: event.data['pug_id'],
                  username: event.data['username'],
                  description: event.data['description'])));
    }
    if (event.data['type'] == "like") {
       navigatorKey
          .currentState
          ?.push(MaterialPageRoute(builder: (context) => const TabView.withIndex(initialIndex: 4,)));
    }
  });
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
                  navigatorKey: navigatorKey,

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
                    '/chatlist': (context) => ChatList(
                          onChatlistEvent: () {},
                        ),
                    '/chat': (context) => Chat(),
                    '/pugscomments': (context) => PugComments(),
                    '/follower': (context) => FollowersView(),
                    '/following': (context) => FollowingView(),
                    '/usersblocked': (context) => UsersBlockedView(),
                    '/competition': (context) => Competition(),
                    '/competitionPayment': (context) => CompetitionPayment(),
                    '/editpug': (context) => EditPug(),
                    '/editpugsecond': (context) => EditPugSecond(),
                  },

                  darkTheme: ThemeData(
                    textTheme: GoogleFonts.expletusSansTextTheme(),
                    brightness: Brightness.dark,
                    primaryColorDark: Colors.black,
                    primaryColor: Colors.black54,
                    scaffoldBackgroundColor: Colors.black54,
                    bottomSheetTheme: const BottomSheetThemeData(
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
                  title: 'MyPug',

                  home: const SplashScreen(),
                )),
          );
        },
      ),
    );
  }
}
