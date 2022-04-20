import 'dart:convert';

import 'package:mypug/response/followerresponse.dart';

import '../../response/BaseResponse.dart';
import 'package:http/http.dart'as http;

import '../../util/config.dart';
import '../../util/util.dart';


Future<FollowerResponse> getUserFollowings() async{

  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/user/following";

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
    FollowerResponse data = FollowerResponse.fromJsonData(
        json.decode(response.body));
    return data ;

  }
  else{
    return FollowerResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message']);
  }


}
