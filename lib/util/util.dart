
import 'package:flutter/material.dart';
import 'package:mypug/response/signinresponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

int SUCCESS_CODE = 0;
int ERROR_CODE = 1;
navigateTo(context,view){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => view),
  );
}
navigateWithName(context, String name){
  Navigator.pushNamed(context, name);
}

showSnackBar(context, message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}


Future<void> saveUserData(SignInResponse data) async {

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  sharedPreferences.setString("token", data.token);
  sharedPreferences.setString("username", data.username);

}

Future<String> getCurrentUserToken()async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? token = sharedPreferences.get("token");
  return token.toString();
}

getPhoneWidth(context){
  return MediaQuery.of(context).size.width;
}
getPhoneHeight(context){
  return MediaQuery.of(context).size.height;
}