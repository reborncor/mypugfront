
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/auth/signin/signin.dart';

class SplashScreen extends StatefulWidget {

  final routeName = '/splashscreen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    navigateToApp(true);

  }

  navigateToApp(bool isLogged) async {
    String path = isLogged  ? const SignIn().routeName : const TabView().routeName;
    Future.delayed(Duration.zero, () async {
      await Navigator.pushNamed(context, path);
    });

  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,

      body:  Center(child: Text('SplashScreen'))

    );
  }
}
