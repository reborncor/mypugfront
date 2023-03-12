import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypug/models/signalenum.dart';

import '../../response/BaseResponse.dart';
import '../../util/config.dart';
import '../../util/util.dart';


Future<BasicResponse> signalUser(String username, SignalEnum reason) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  String path = "/user/signal";
  Map data = {"username": username, "reason":reason.name};
  try {
    var url = Uri.parse(URL + path);
    response = await http.post(url,
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
