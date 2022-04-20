
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/features/auth/api.dart';

import '../../../components/tab/tab.dart';
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

  @override
  void initState() {
    super.initState();

  }

  Widget userForm(){

    return Center( child: SingleChildScrollView(scrollDirection: Axis.vertical , child: Form(
        key: _formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            const Padding(padding: EdgeInsets.only(bottom: 4),
                child: Text("MyPUG",style: TextStyle( fontSize: 20),)),
            Padding(padding: const EdgeInsets.all(16),
                child:   TextFormField(
                  autofillHints:const <String>[AutofillHints.username],
                  textAlign: TextAlign.center,
                  controller: usernameController,
                  validator:(value) {
                    if (value == null || value.isEmpty) {
                      return "Entre votre nom d'utilisateur";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(

                    hintText: "Nom d'utilisateur",
                  ),
                )),
            Padding(padding: const EdgeInsets.all(16),
                child:   TextFormField(
                  autofillHints:const <String>[AutofillHints.telephoneNumber],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  controller: phoneNumberController,
                  validator:(value) {
                    if (value == null || value.isEmpty) {
                      return "Entre votre numéro de téléphone";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(

                    hintText: "Numéro de téléphone",
                  ),
                )),
            Padding(padding: const EdgeInsets.all(16),
                child:   TextFormField(

                  autofillHints:const <String>[AutofillHints.email],
                  textAlign: TextAlign.center,
                  controller: emailController,
                  validator:(value) {
                    if (value == null || value.isEmpty) {
                      return "Entrer votre adresse email";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(

                    hintText: "Adresse email",
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
                decoration: const InputDecoration(

                  hintText: 'Mot de passe',
                ),
              ),)
            ,
            Padding(padding: EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () async {

                  if(_formkey.currentState!.validate()){

                    var result =  await signUpUSer(usernameController.text, passwordController.text, phoneNumberController.text, emailController.text);
                    print(result);
                    if(result.code == SUCCESS_CODE) {
                      navigateWithName(context, const TabView().routeName);
                    }else{
                      showSnackBar(context, result.message);
                    }
                  }


                },
                child: const Text("S'inscrire"),
              ),),
          ],
        )
    ),),);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),

        body:  userForm()

    );
  }
}
