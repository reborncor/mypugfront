
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

navigateWithNamePop(context, String name){
  Navigator.popAndPushNamed(context, name);
}

showSnackBar(context, message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(duration: const Duration(milliseconds: 1500),content: Text(message)),
  );
}
showToast(context, message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

Future<void> saveUserData(SignInResponse data) async {

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  sharedPreferences.setString("token", data.token);
  sharedPreferences.setString("username", data.username);
  sharedPreferences.setString("email", data.email);
  sharedPreferences.setString("phoneNumber", data.phoneNumber);

}


Future<void> saveUserFirstUse(SignInResponse data) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("firstUse", "firstUse");

}

Future<String> getUserFirstUse()async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? firstUse = sharedPreferences.get("firstUse");
  return firstUse.toString();
}



deleteData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove("token");
  sharedPreferences.remove("username");
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
