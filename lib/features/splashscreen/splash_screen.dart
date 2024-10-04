import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/auth/signin/signin.dart';
import 'package:mypug/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../util/util.dart';

class SplashScreen extends StatefulWidget {
  final routeName = '/splashscreen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool isUserLogged = false;
  bool isFirstTimeAppOpen = false;

  Future checkFirstOpenApp() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getBool("isFirstTimeAppOpen") == null) {
      isFirstTimeAppOpen = true;
      sharedPreferences.setBool("isFirstTimeAppOpen", false);
    }
    setState(() {});
  }

  @override
  void initState() {
    checkFirstOpenApp().then((value) {
      fetchData();
    });
    super.initState();
  }

  fetchData() async {
    String data = await getCurrentUserToken();
    if (data.length > 5) {
      isUserLogged = true;
    }
    if (!isFirstTimeAppOpen) {
      Timer(const Duration(milliseconds: 500), () {
        navigateToApp(isUserLogged);
      });
    }
  }

  navigateToApp(bool isLogged) async {
    String path =
        isLogged ? const TabView().routeName : const SignIn().routeName;
    Future.delayed(Duration.zero, () async {
      await navigateWithNamePop(context, path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isFirstTimeAppOpen
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Image.asset("asset/images/logo.png", width: 80, height: 80),
                    const Text(
                      "Welcome to MyPug",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: SlideAction(
                        height: 55,
                        animationDuration: const Duration(milliseconds: 300),
                        reversed: false,
                        submittedIcon: const Icon(Icons.done),
                        sliderButtonIconPadding: 10,
                        sliderButtonIcon: const Icon(Icons.arrow_forward),
                        text: "Continue To MyPug",
                        textStyle: const TextStyle(fontSize: 18),
                        innerColor: APP_COLOR_SEARCH,
                        outerColor: APPCOLOR,
                        onSubmit: () {
                          navigateToApp(isUserLogged);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child:
                    Image.asset("asset/images/logo.png", width: 80, height: 80),
              ));
  }
}
