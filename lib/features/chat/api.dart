import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypug/response/conversationsresponse.dart';

import '../../response/conversationresponse.dart';
import '../../response/oldmessageresponse.dart';
import '../../util/config.dart';
import '../../util/util.dart';

Future<ConversationsResponse> getUserConversations() async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/conversation/getconversations";

  try {
    var url = Uri.parse(URL + path);
    response = await http.get(url, headers: {
      "Content-type": "application/json",
      'Authorization': 'Bearer ' + token
    });
  } catch (e) {
    print(e.toString());

    return json.decode(response.body);
  }

  if (response.statusCode == 200) {
    ConversationsResponse data =
        ConversationsResponse.fromJsonData(json.decode(response.body));
    return data;
  } else {
    return ConversationsResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}

Future<ConversationResponse> getUserConversation(String username) async {
  String token = await getCurrentUserToken();
  http.Response response;
  const String path = "/conversation/getconversation";
  Map data = {
    'username': username,
  };
  try {
    var url = Uri.parse(URL + path);
    response = await http.post(url,
        headers: {
          "Content-type": "application/json",
          'Authorization': 'Bearer ' + token
        },
        body: json.encode(data));
  } catch (e) {
    print(e.toString());
    return ConversationResponse(message: "Erreur serveur", code: 1);
  }

  if (response.statusCode == 200) {
    ConversationResponse data =
        ConversationResponse.fromJsonData(json.decode(response.body));
    return data;
  } else {
    return ConversationResponse(code: 1, message: "Une Erreur est survenue");
  }
}

Future<OldMessageResponse> getUserMessagePageable(
    String username, int startInd, int endInd) async {
  String token = await getCurrentUserToken();
  http.Response response;
  const String path = "/conversation/getconversationpage";
  try {
    final queryParameters = {
      'username': username,
      'startInd': startInd.toString(),
      'endInd': endInd.toString(),
    };
    var url = Uri.parse(URL + path).replace(queryParameters: queryParameters);

    response = await http.get(
      url,
      headers: {
        "Content-type": "application/json",
        'Authorization': 'Bearer ' + token
      },
    );
  } catch (e) {
    print(e.toString());
    return OldMessageResponse(message: "Erreur serveur", code: 1);
  }

  if (response.statusCode == 200) {
    OldMessageResponse data =
        OldMessageResponse.fromJsonData(json.decode(response.body));
    return data;
  } else {
    return OldMessageResponse(code: 1, message: "Erreur serveur");
  }
}
