import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mypug/response/baseresponse.dart';
import 'package:mypug/response/competitionresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';

Future<CompetitionReponse> findCompetiton() async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/competition/643c3c2d9fe950d2dcc07aa4";

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
      CompetitionReponse data =
          CompetitionReponse.fromJsonData(json.decode(response.body));
      log(data.toString());
      return data;
    } catch (e) {
      print("ERREUR");
      print(e);
    }
    return CompetitionReponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  } else {
    return CompetitionReponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}

Future<BasicResponse> buyPlaceCompetition(int amount) async{
  var response;

  final String path = "/user/createpayment";
  String token = await getCurrentUserToken();
  Map data = {
    "amount":amount,
    "currency":"eur",
  };
  try {
    var url = Uri.parse(URL + path);

    response = await http.post(url,
        headers: {"Content-type": "application/json",'Authorization': 'Bearer '+ token}, body: json.encode(data));
    BasicResponse result = BasicResponse.fromJsonData(json.decode(response.body));
    return result ;
  }
  catch (e) {
    print(e.toString());
    return BasicResponse(code: 1, message: json.decode(response.body)['message'], payload: null);
  }



}

