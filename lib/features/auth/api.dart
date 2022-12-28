import 'dart:convert';

import 'package:mypug/response/signinresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;

Future<SignInResponse> signinUser(String username, String password) async{
  http.Response response;

  const String path = "/user/signin";

  Map data =  {
    'username' : username.toLowerCase(),
    'password' : password
  };
  try {

    var url = Uri.parse(URL+path);
    response = await http.post(url,
        headers: {"Content-type": "application/json"}, body: json.encode(data));
  }
  catch (e) {
    print(e.toString());
    return SignInResponse(code: 1, message: "Erreur serveur");
  }

  if(response.statusCode == 200) {
    SignInResponse data = SignInResponse.fromJsonData(json.decode(response.body));
    print(json.decode(response.body));
    if(data != null) {
      saveUserData(data);
    }
    return data ;
  }
  else{
    var message;
    try{
      message = json.decode(response.body)['message'];
    }catch(e){
      message = "Une erreur est survenue";
    }
    return SignInResponse(code: json.decode(response.body)['code'], message: message);
  }


}
Future<SignInResponse> signUpUSer(String username, String password, String phoneNumber, String email) async{
  http.Response response;

  const String path = "/user/signup";

  Map data =  {
    'username' : username.toLowerCase(),
    'password' : password,
    'phoneNumber' : phoneNumber,
    'email' : email
  };
  try {

    var url = Uri.parse(URL+path);
    response = await http.post(url,
        headers: {"Content-type": "application/json"}, body: json.encode(data));
  }
  catch (e) {
    print(e.toString());
    return SignInResponse(code: 1, message: "Erreur serveur");
  }

  if(response.statusCode == 201) {
    SignInResponse data = SignInResponse.fromJsonData(json.decode(response.body));
    print(json.decode(response.body));
    if(data != null) {
      saveUserData(data);
    }
    return data ;
  }
  else{
    var message;
    try{
      message = json.decode(response.body)['message'];
    }catch(e){
      message = "Une erreur est survenue";
    }
    return SignInResponse(code: json.decode(response.body)['code'], message: message);
  }


}
