import 'dart:convert';



import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:mypug/response/baseresponse.dart';
import 'package:mypug/response/signinresponse.dart';
import 'package:mypug/response/userpugresponse.dart';
import 'package:mypug/response/userresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';



Future<BasicResponse> likePug(String pugId, String userPug) async{

  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/pug/like";


  Map data = {
    "pugId":pugId,
    "username":userPug
  };

  try {
    var url = Uri.parse(URL+path);
    response = await http.put(url,
        headers: {"Content-type": "application/json",'Authorization': 'Bearer '+ token},  body: json.encode(data));
  }
  catch (e) {
    print(e.toString());

    return json.decode(response.body);
  }

  if(response.statusCode == 200) {
    print(response.contentLength);

    try {
      BasicResponse data = BasicResponse.fromJsonData(
          json.decode(response.body));
      return data ;
    }catch(e){
      print("ERREUR");
      print(e);
    }
    return BasicResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message'], payload: null);

  }
  else{
    return BasicResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message'], payload: null);
  }


}

