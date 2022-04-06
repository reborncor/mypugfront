import 'dart:convert';



import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:mypug/response/userpugresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';



Future<UserPugResponse> getAllPugsFromUser() async{

  String token = await getCurrentUserToken();
  var response;
  const String path = "/pug/getall";

  try {
    var url = Uri.parse(URL+path);
    response = await http.get(url,
        headers: {"Content-type": "application/json",'Authorization': 'Bearer '+ token});
  }
  catch (e) {
    print(e.toString());
    return json.decode(response.body);
  }

  if(response.statusCode == 200) {
    UserPugResponse data = UserPugResponse.fromJsonData(json.decode(response.body));
    return data ;
  }
  else{
    return UserPugResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message']);
  }


}
