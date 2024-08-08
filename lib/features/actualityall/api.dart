import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypug/response/actualityresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';

Future<ActualityResponse> getActualityPageable(int startInd, int endInd) async {
  String token = await getCurrentUserToken();
  var response;

  const String path = "/pug/actualityall";
  final queryParameters = {
    "startInd": startInd.toString(),
    "endInd": endInd.toString(),
  };
  try {
    var url = Uri.parse(URL + path).replace(queryParameters: queryParameters);
    response = await http.get(url, headers: {
      "Content-type": "application/json",
      'Authorization': 'Bearer ' + token
    });
  } catch (e) {
    print(e.toString());

    return ActualityResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }

  if (response.statusCode == 200) {
    ActualityResponse data =
        ActualityResponse.fromJsonData(json.decode(response.body));
    return data;
  } else {
    return ActualityResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}
