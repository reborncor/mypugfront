import 'dart:convert';

import 'package:http/http.dart'as http;
import 'package:mypug/response/followerresponse.dart';

import '../../util/config.dart';
import '../../util/util.dart';

Future<FollowerResponse> getUserFollowers(String username) async{

  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/user/followers";

  try {
    final queryParameters = {
      'username': username,
    };
    var url = Uri.parse(URL+path).replace(queryParameters: queryParameters);

    response = await http.get(url,
        headers: {"Content-type": "application/json",'Authorization': 'Bearer '+ token});
  }
  catch (e) {
    print(e.toString());

    return json.decode(response.body);
  }

  if(response.statusCode == 200) {
    FollowerResponse data = FollowerResponse.fromJsonData(
        json.decode(response.body));
    return data ;

  }
  else{
    return FollowerResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message']);
  }


}





