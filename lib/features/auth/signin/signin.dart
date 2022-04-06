
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/auth/signup/signup.dart';
import 'package:mypug/util/util.dart';

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

  @override
  void initState() {
    super.initState();

  }

  Widget userForm(){

    return Form(
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

                var result =  await signinUser(usernameController.text, passwordController.text);
                print(result);
                if(result.code == SUCCESS_CODE) {
                  navigateWithName(context, const TabView().routeName);
                }else{
                  showSnackBar(context, result.message);
                }
              }
              else{
                log("invalide");
                navigateWithName(context, const TabView().routeName);
              }

            },
            child: const Text('Se connecter'),
          ),),
        ElevatedButton(
          onPressed: ()  {
            Navigator.pushNamed(context, const SignUp().routeName);
          },
          child: const Text("S'inscrire"),
        )
      ],
    )
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,

        body:  Center(
            child :userForm()
        )

    );
  }


}
