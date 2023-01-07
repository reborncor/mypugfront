
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/auth/signin/signin.dart';

import '../../util/util.dart';

class SplashScreen extends StatefulWidget {

  final routeName = '/splashscreen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  bool isUserLogged = false;

  @override
  void initState() {
    fetchData();
    super.initState();

  }

  fetchData() async {
    String data = await getCurrentUserToken();
    if (data.length > 5 ){
      isUserLogged = true;
    }
    navigateToApp(isUserLogged);

  }

  navigateToApp(bool isLogged) async {
    String path = isLogged  ? const TabView().routeName : const SignIn().routeName ;
    Future.delayed(Duration.zero, () async {
      await navigateWithNamePop(context, path);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(child: Image.asset("asset/images/logo.png", width: 80, height: 80),)

    );
  }
}
