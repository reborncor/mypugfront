import 'package:flutter/material.dart';
import 'package:mypug/features/auth/signin/signin.dart';
import 'package:mypug/features/resetpassword/api.dart';
import 'package:provider/provider.dart';

import '../../../components/design/design.dart';
import '../../../service/themenotifier.dart';
import '../../../util/util.dart';

class ResetPasswordConfirmed extends StatefulWidget {
  final routeName = '/resetpasswordconfirmed';
  final String? username;

  const ResetPasswordConfirmed({Key? key, this.username}) : super(key: key);

  @override
  ResetPasswordConfirmedState createState() => ResetPasswordConfirmedState();
}

class ResetPasswordConfirmedState extends State<ResetPasswordConfirmed> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmedPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget resetForm() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      "Insérrer un nouveau mot de passe :"+widget.username.toString(),
                      style: TextStyle(fontSize: 14),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.password],
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Entrer un mot de passe";
                      }
                      if (value.length < 7) {
                        return "Inserrez 8 caractères minimum";
                      }
                      return null;
                    },
                    controller: passwordController,
                    maxLength: 50,
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
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.password],
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Entrer un mot de passe";
                      }
                      if (value.length < 7) {
                        return "Inserrez 8 caractères minimum";
                      }
                      if (value != passwordController.text) {
                        return "Les mots de passe ne sont pas identiques";
                      }
                      return null;
                    },
                    controller: confirmedPasswordController,
                    maxLength: 50,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      focusedBorder: setOutlineBorder(1.5, 20.0),
                      enabledBorder: setOutlineBorder(1.5, 20.0),
                      border: setOutlineBorder(1.5, 20.0),
                      hintText: 'Confirmer votre mot de passe',
                    ),
                  ),
                ),                Padding(
                  padding: EdgeInsets.all(12),
                  child: ElevatedButton(
                    style: BaseButtonRoundedColor(60, 40, Colors.indigo[300]),
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {

                        var result = await changePassword(
                             widget.username!,passwordController.text
                            );
                        if (result.code == SUCCESS_CODE) {
                          showSnackBar(context, result.message);
                          navigateWithNamePop(context, const SignIn().routeName);
                        } else {
                          showSnackBar(context, result.message);
                        }
                      }
                    },
                    child: const Text("Changer de mot de passe"),
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
              title: Text("Réinitialisation du mot de passe"),
              backgroundColor: Colors.black,
            ),
            body: Container(
                decoration: BoxGradient(),
                child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      child: resetForm(),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ))));
      },
    );
  }
}
