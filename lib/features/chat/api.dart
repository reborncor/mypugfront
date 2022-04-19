import 'dart:convert';

import 'package:mypug/response/conversationsresponse.dart';

import '../../util/config.dart';
import '../../util/util.dart';
import 'package:http/http.dart'as http;

Future<ConversationsResponse> getUserConversations() async{

  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/conversation/getconversations";

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
    ConversationsResponse data = ConversationsResponse.fromJsonData(
        json.decode(response.body));
    return data ;

  }
  else{
    return ConversationsResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message']);
  }


}