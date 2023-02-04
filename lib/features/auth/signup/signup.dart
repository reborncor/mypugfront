import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/features/auth/api.dart';
import 'package:provider/provider.dart';

import '../../../components/design/design.dart';
import '../../../components/tab/tab.dart';
import '../../../service/themenotifier.dart';
import '../../../util/util.dart';

class SignUp extends StatefulWidget {
  final routeName = '/signup';

  const SignUp({Key? key}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final countryPicker = const FlCountryCodePicker();
  late String dialCode = '+33';

  @override
  void initState() {
    super.initState();
  }

  Widget userForm() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      "MyPUG",
                      style: TextStyle(fontSize: 20),
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
                        hintText: "Nom d'utilisateur *",
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      autofillHints: const <String>[AutofillHints.email],
                      textAlign: TextAlign.center,
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Entre votre adresse email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: setOutlineBorder(1.5, 20.0),
                        enabledBorder: setOutlineBorder(1.5, 20.0),
                        border: setOutlineBorder(1.5, 20.0),
                        hintText: "Adresse email *",
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                              width: 1.5,
                              color: Colors.indigo[300] ?? Colors.indigo)),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final code = await countryPicker.showPicker(

                                scrollToDeviceLocale: true,

                                  context: context);
                              if (code != null) {
                                print(code);
                                dialCode = code.dialCode;
                              }
                              ;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              margin:
                                  const EdgeInsets.only(left: 8.0),
                              decoration:  BoxDecoration(
                                  color:Colors.indigo.shade300,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              child: Text(dialCode.toString(),
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          Expanded(
                              child: TextFormField(
                            autofillHints: const <String>[
                              AutofillHints.telephoneNumber
                            ],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            controller: phoneNumberController,

                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Numéro de téléphone",
                            ),
                          ))
                        ],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(16),
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
                      border: setOutlineBorder(1.5, 20.0),
                      hintText: 'Mot de passe',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: ElevatedButton(
                    style: BaseButtonRoundedColor(60, 40, Colors.indigo[300]),
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        var result = await signUpUSer(
                            usernameController.text,
                            passwordController.text,
                            phoneNumberController.text,
                            emailController.text);
                        print(result);
                        if (result.code == SUCCESS_CODE) {
                          navigateWithName(context, const TabView().routeName);
                        } else {
                          showSnackBar(context, result.message);
                        }
                      }
                    },
                    child: const Text("S'inscrire"),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Inscription"),
              backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
            ),
            body: Container(
                decoration: BoxGradient(),
                child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      child: userForm(),
                      decoration: BoxDecoration(
                        color: notifier.isDark ? Colors.black : Colors.white70,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ))));
      },
    );
  }
}
