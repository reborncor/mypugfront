import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypug/response/userfindresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';

import '../../response/BaseResponse.dart';

Future<UserFindResponse> findAllUsers(String username) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/user/find";

  try {
    final queryParameters = {
      'username': username,
    };
    var url = Uri.parse(URL + path).replace(queryParameters: queryParameters);

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
      UserFindResponse data =
          UserFindResponse.fromJsonData(json.decode(response.body));

      return data;
    } catch (e) {
      print("ERREUR");
      print(e);
    }
    return UserFindResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  } else {
    return UserFindResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}

Future<BasicResponse> followUser(String username) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  String path = "/user/follow";

  Map data = {"username": username};

  try {
    var url = Uri.parse(URL + path);
    response = await http.put(url,
        headers: {
          "Content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data));
  } catch (e) {
    print(e.toString());

    return json.decode(response.body);
  }

  if (response.statusCode == 200) {
    print(response.contentLength);

    try {
      BasicResponse data =
          BasicResponse.fromJsonData(json.decode(response.body));
      return data;
    } catch (e) {
      print("ERREUR");
      print(e);
    }
    return BasicResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message'],
        payload: null);
  } else {
    return BasicResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message'],
        payload: null);
  }
}
