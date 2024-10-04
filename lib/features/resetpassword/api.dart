import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mypug/response/baseresponse.dart';
import '../../util/config.dart';
import '../../util/util.dart';

Future<BasicResponse> resetPassword(
    String username) async {
  late http.Response response;
  String path ="/user/resetpassword";
  Map data = {"username": username};

  try {
    var url = Uri.parse(URL + path);
    response = await http.post(url,
        headers: {
          "Content-type": "application/json",
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

Future<BasicResponse> changePassword(
    String username, String password) async {
  late http.Response response;
  String path ="/user/changePassword";
  Map data = {"username": username,"password": password};

  try {
    var url = Uri.parse(URL + path);
    response = await http.put(url,
        headers: {
          "Content-type": "application/json",
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
