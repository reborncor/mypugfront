import 'dart:convert';

import 'package:mypug/response/followerresponse.dart';

import '../../response/BaseResponse.dart';
import 'package:http/http.dart'as http;

import '../../util/config.dart';
import '../../util/util.dart';

Future<FollowerResponse> getUserFollowers() async{

  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/user/followers";

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




// Future<BasicResponse> followUser(String pugId, String userPug, bool like) async{
//
//   String token = await getCurrentUserToken();
//   late http.Response response;
//   String path = (like) ? "/pug/like" : "/pug/unlike";
//
//
//   Map data = {
//     "pugId":pugId,
//     "username":userPug
//   };
//
//   try {
//     var url = Uri.parse(URL+path);
//     response = await http.put(url,
//         headers: {"Content-type": "application/json",'Authorization': 'Bearer '+ token},  body: json.encode(data));
//   }
//   catch (e) {
//     print(e.toString());
//
//     return json.decode(response.body);
//   }
//
//   if(response.statusCode == 200) {
//     print(response.contentLength);
//
//     try {
//       BasicResponse data = BasicResponse.fromJsonData(
//           json.decode(response.body));
//       return data ;
//     }catch(e){
//       print("ERREUR");
//       print(e);
//     }
//     return BasicResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message'], payload: null);
//
//   }
//   else{
//     return BasicResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message'], payload: null);
//   }
//
//
// }
//
//




