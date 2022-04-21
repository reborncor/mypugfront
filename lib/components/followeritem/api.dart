
import 'dart:convert';

import 'package:mypug/response/followerresponse.dart';

import '../../response/BaseResponse.dart';
import 'package:http/http.dart'as http;

import '../../util/config.dart';
import '../../util/util.dart';

Future<BasicResponse> unFollowOrFollowUser(String username, bool unfollow) async{

  String token = await getCurrentUserToken();
  late http.Response response;
  String path = (unfollow) ? "/user/unfollow" : "/user/follow";


  Map data = {
    "username":username
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
