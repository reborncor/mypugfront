import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypug/response/followerresponse.dart';

import '../../util/config.dart';
import '../../util/util.dart';

Future<FollowerResponse> getUserBlocked() async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/user/blocked";

  try {
    var url = Uri.parse(URL + path);
    response = await http.get(url, headers: {
      "Content-type": "application/json",
      'Authorization': 'Bearer $token',
    });
  } catch (e) {
    print(e.toString());
    return json.decode(response.body);
  }

  if (response.statusCode == 200) {
    try {
      FollowerResponse data =
          FollowerResponse.fromJsonData(json.decode(response.body));
      return data;
    } catch (e) {
      print(e);
      return FollowerResponse(
          code: json.decode(response.body)['code'],
          message: json.decode(response.body)['message']);
    }
  } else {
    return FollowerResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}
