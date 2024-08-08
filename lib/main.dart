import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  runApp(const MyApp());
}

void httpCheck() {
  HttpOverrides.global = MyHttpOverrides();
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> setUpEnv() async {
  await dotenv.load();
  STRIPE_KEY = dotenv.get('STRIPE_KEY', fallback: 'STRIPE_KEY N/A');
  Stripe.publishableKey = STRIPE_KEY;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  NOTIFICATION_TOKEN = (await _firebaseMessaging.getToken())!;
  log(NOTIFICATION_TOKEN.toString());

  await FlutterNotificationChannel.registerNotificationChannel(
    description: 'Basic notification',
    id: 'vibratenow',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'App notification',
    enableSound: true,
    enableVibration: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
    print("message received");
    print(event.notification?.title);

    // Display local notification when a message is received
    await _showNotification(event);
  });

  FirebaseMessaging.onBackgroundMessage((firebaseMessagingBackgroundHandler));

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) async {
    print("message clicked");
    print(event.notification?.title);
    gotoRouteOnTapNotification(event.data);
  });
}

gotoRouteOnTapNotification(Map data) {
  if (data['type'] == "message") {
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => Chat.withUsername(
        receiverUser: UserFactory(
            id: "",
            username: data['sender_username'],
            profilePicture: data['sender_profilepicture']),
        seen: false,
      ),
    ));
  }
  if (data['type'] == "comment") {
    navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => PugComments.withData(
            pugId: data['pug_id'],
            username: data['username'],
            description: data['description'])));
  }
  if (data['type'] == "like") {
    navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => const TabView.withIndex(
              initialIndex: 4,
            )));
  }
}

Future<void> _showNotification(RemoteMessage event) async {
  try {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      "channel_id_1",
      "channel_name_1",
      importance: Importance.max,
      icon: '@mipmap/launcher_icon',
      priority: Priority.high,
      ticker: 'ticker',
    );

    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    String payloadJson = jsonEncode({
      "type": event.data['type'],
      "pug_id": event.data['pug_id'],
      "username": event.data['username'],
      "description": event.data['description']
    });

    await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        event.notification?.title ?? 'New Message',
        event.notification?.body ?? '',
        platformChannelSpecifics,
        payload: payloadJson);

    var intializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/launcher_icon');
    IOSInitializationSettings initializationSettingsIOS =
        const IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationSettings = InitializationSettings(
        android: intializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (message) async {
      gotoRouteOnTapNotification(jsonDecode(message!));

      log("TAPPPPPPPPPPPP-${message}");
    });
  } catch (e) {
    log(e.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        routes: {
          '/actualityall': (context) => const ActualityAll(),
          '/actuality': (context) => const Actuality(),
          '/create': (context) => const CreatePug(),
          '/profile': (context) => Profile(),
          '/setting': (context) => const Setting(),
          '/tabview': (context) => const TabView(),
          '/signin': (context) => const SignIn(),
          '/signup': (context) => const SignUp(),
          '/pug': (context) => const Pug(),
          '/search': (context) => const Search(),
          '/chatlist': (context) => ChatList(
                onChatlistEvent: () {},
              ),
          '/chat': (context) => Chat(),
          '/pugscomments': (context) => PugComments(),
          '/follower': (context) => FollowersView(),
          '/following': (context) => FollowingView(),
          '/usersblocked': (context) => UsersBlockedView(),
          '/competition': (context) => const Competition(),
          '/competitionPayment': (context) => const CompetitionPayment(),
          '/editpug': (context) => const EditPug(),
          '/editpugsecond': (context) => const EditPugSecond(),
        },
        darkTheme: ThemeData(
          fontFamily: GoogleFonts.expletusSans().fontFamily,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black54),
          brightness: Brightness.dark,
          primaryColorDark: Colors.black,
          primaryColor: Colors.black54,
          scaffoldBackgroundColor: Colors.black54,
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.black54,
            modalBackgroundColor: Colors.black54,
          ),
        ),
        themeMode: ThemeMode.dark,
        title: 'MyPug',
        home: const SplashScreen(),
      ),
    );
  }
}
