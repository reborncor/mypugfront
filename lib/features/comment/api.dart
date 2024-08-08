import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mypug/response/commentresponse.dart';

import '../../util/config.dart';
import '../../util/util.dart';

Future<CommentResponse> getPugComment(String pugId, String username) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/pug/comment";
  try {
    final queryParameters = {
      'username': username,
      'pugId': pugId,
    };
    var url = Uri.parse(URL + path).replace(queryParameters: queryParameters);

    response = await http.get(url, headers: {
      "Content-type": "application/json",
      'Authorization': 'Bearer ' + token
    });
  } catch (e) {
    print(e.toString());
    return json.decode(response.body);
  }

  if (response.statusCode == 200) {
    CommentResponse data =
        CommentResponse.fromJsonData(json.decode(response.body));

    return data;
  } else {
    return CommentResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}
