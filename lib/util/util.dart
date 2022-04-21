
import 'package:flutter/material.dart';
import 'package:mypug/response/signinresponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/socketservice.dart';

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
  sharedPreferences.setString("email", data.email);
  sharedPreferences.setString("phoneNumber", data.phoneNumber);


}


deleteData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.clear();
}
Future<String> getCurrentUserToken()async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? token = sharedPreferences.get("token");
  return token.toString();
}


Future<dynamic> getUserData()async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? username = sharedPreferences.get("username");
  Object? phoneNumber = sharedPreferences.get("phoneNumber");
  Object? email = sharedPreferences.get("email");

  return {
    "username" : username.toString(),
    "phoneNumber" : phoneNumber.toString(),
    "email" : email.toString(),
  };
}

Future<String> getCurrentUsername()async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? username = sharedPreferences.get("username");
  return username.toString();
}

getPhoneWidth(context){
  return MediaQuery.of(context).size.width;
}
getPhoneHeight(context){
  return MediaQuery.of(context).size.height;
}

SocketService socketService = SocketService();
