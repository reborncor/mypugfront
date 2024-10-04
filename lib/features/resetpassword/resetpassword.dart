import 'package:flutter/material.dart';
import 'package:mypug/features/resetpassword/api.dart';
import 'package:provider/provider.dart';

import '../../../components/design/design.dart';
import '../../../service/themenotifier.dart';
import '../../../util/util.dart';

class ResetPassword extends StatefulWidget {
  final routeName = '/resetpassword';

  const ResetPassword({Key? key}) : super(key: key);

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();

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
                const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      "Insérrer votre nom d'utilisateur",
                      style: TextStyle(fontSize: 14),
                    )),
                Padding(
                    padding: const EdgeInsets.only(
                        top: 4, left: 16, right: 16, bottom: 0),
                    child: TextFormField(
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
                      },
                      textCapitalization: TextCapitalization.none,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.username],
                      textAlign: TextAlign.center,
                      maxLength: 25,
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
                  padding: EdgeInsets.all(12),
                  child: ElevatedButton(
                    style: BaseButtonRoundedColor(60, 40, Colors.indigo[300]),
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        var result = await resetPassword(
                            usernameController.text.trim()
                            );
                        if (result.code == SUCCESS_CODE) {
                          showSnackBar(context, result.message);
                        } else {
                          showSnackBar(context, result.message);
                        }
                      }
                    },
                    child: const Text("Envoyer un email"),
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
              title: Text("Mot de passe oublié"),
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
