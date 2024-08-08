import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/auth/signup/signup.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:mypug/response/baseresponse.dart';



import '../../../components/design/design.dart';
import '../api.dart';

class SignIn extends StatefulWidget {
  final routeName = '/signin';

  const SignIn({Key? key}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late ThemeModel notifier;
  late String _errorText = "";

  @override
  void initState() {
    super.initState();
  }

  Widget userForm() {
    return Form(
        key: _formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Image(
                  image: AssetImage("asset/images/logo.png"),
                  width: 100,
                  height: 100,
                )),
            Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                    autofillHints: const <String>[AutofillHints.username],
                    textAlign: TextAlign.center,
                    controller: usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Entre votre nom d'utilisateur";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: setOutlineBorder(1.5, 20.0),
                      enabledBorder: setOutlineBorder(1.5, 20.0),
                      border: setOutlineBorder(1.5, 20.0),
                      hintText: "Nom d'utilisateur",
                    ))),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 16, left: 16, right: 16),
              child: TextFormField(
                autofillHints: const <String>[AutofillHints.password],
                textAlign: TextAlign.center,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Entrer un mot de passe";
                  }
                  return null;
                },
                controller: passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  focusedBorder: setOutlineBorder(1.5, 20.0),
                  enabledBorder: setOutlineBorder(1.5, 20.0),
                  border: setOutlineBorder(1.5, 25.0),
                  hintText: 'Mot de passe',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Visibility(
                visible: !_errorText.isEmpty,
                child: Text(
                  _errorText,
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: ElevatedButton(
                style: BaseButtonRoundedColor(60, 40, Colors.indigo[300]),
                onPressed: () async {
                  if (_formkey.currentState!.validate()) {
                    var result = await signinUser(
                        usernameController.text.trim(),
                        passwordController.text);
                    log("Connection");
                    if (result.code == SUCCESS_CODE) {
                      this.notifier.isDark = true;
                      navigateWithNamePop(context, const TabView().routeName);
                    } else {
                      // showSnackBar(context, result.message);
                      log("Error");

                      setState(() {
                        _errorText = result.message;
                      });
                    }
                  }
                },
                child: const Text('Se connecter'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, const SignUp().routeName);
              },
              child: Text(
                "Pas encore inscrit ? crééz vous un compte",
                style: TextStyle(color: Colors.indigo.shade300),
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            resizeToAvoidBottomInset: false, body: Center(child: userForm()));
      },
    );
  }
}
