import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:minio/minio.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/baseresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';
import 'package:simple_s3/simple_s3.dart';

Future<BasicResponse> likeOrUnlikePug(
    String pugId, String userPug, bool like) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  String path = (like) ? "/pug/like" : "/pug/unlike";

  Map data = {"pugId": pugId, "username": userPug};

  try {
    var url = Uri.parse(URL + path);
    response = await http.put(url,
        headers: {
          "Content-type": "application/json",
          'Authorization': 'Bearer ' + token
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

Future<BasicResponse> sendComment(
    String pugId, String userPug, String comment) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/pug/comment";

  Map data = {"pugId": pugId, "comment": comment, "username": userPug};

  try {
    var url = Uri.parse(URL + path);
    response = await http.put(url,
        headers: {
          "Content-type": "application/json",
          'Authorization': 'Bearer ' + token
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

Future<BasicResponse> deletePug(
    String pugId, String userPug, String imageUrl) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/pug/delete";

  Map data = {"pugId": pugId, "username": userPug};

  try {
    var url = Uri.parse(URL + path);

    response = await http.put(url,
        headers: {
          "Content-type": "application/json",
          'Authorization': 'Bearer ' + token
        },
        body: json.encode(data));

    final minio = Minio(
        endPoint: 's3.amazonaws.com',
        accessKey: AWS_ACCESSKEY,
        secretKey: AWS_SECRETKEY,
        region: AWSRegions.euWest3.region);
    try {
      await minio.removeObject(
          AWS_BUCKETNAME, imageUrl.replaceAll('$AWS_URL/', ''));
    } catch (e) {}
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

Future<BasicResponse<PugModel?>> getPug(String pugId, String username) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/pug/get";

  Map data = {"pugId": pugId, "username": username};

  try {
    var url = Uri.parse(URL + path);
    response = await http.put(url,
        headers: {
          "Content-type": "application/json",
          'Authorization': 'Bearer ' + token
        },
        body: json.encode(data));
  } catch (e) {
    print(e.toString());

    return json.decode(response.body);
  }

  if (response.statusCode == 200) {
    print(response.contentLength);

    try {
      BasicResponse<PugModel> data =
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
