import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:minio/io.dart';
import 'package:minio/minio.dart';
import 'package:mypug/response/userpugresponse.dart';
import 'package:mypug/response/userresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';
import 'package:simple_s3/simple_s3.dart';

Future<UserPugResponse> getAllPugsFromUser() async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/pug/getall";

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
      UserPugResponse data =
          UserPugResponse.fromJsonData(json.decode(response.body));
      return data;
    } catch (e) {
      print("ERREUR");
      print(e);
    }
    return UserPugResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  } else {
    return UserPugResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}

Future<UserPugResponse> getAllPugsFromUsername(String username) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/pug/getallfromuser";

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
      UserPugResponse data =
          UserPugResponse.fromJsonData(json.decode(response.body));
      return data;
    } catch (e) {
      print("ERREUR");
      print(e);
    }
    return UserPugResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  } else {
    return UserPugResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}

Future<UserResponse> getUserInfo() async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/user/info";

  try {
    var url = Uri.parse(URL + path);
    response = await http.get(url, headers: {
      "Content-type": "application/json",
      'Authorization': 'Bearer $token',
    });
  } catch (e) {
    log("Error");
    print(e.toString());
    return json.decode(response.body);
  }

  if (response.statusCode == 200) {
    UserResponse data = UserResponse.fromJsonData(json.decode(response.body));
    return data;
  } else {
    return UserResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}

Future<UserResponse> getUserInfoFromUsername(String username) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  const String path = "/user/get";

  try {
    final queryParameters = {
      'username': username,
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
    UserResponse data = UserResponse.fromJsonData(json.decode(response.body));
    return data;
  }
  if (response.statusCode == 400 &&
      json.decode(response.body)['code'] == BLOCKED_CODE) {
    return UserResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  } else {
    return UserResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message']);
  }
}

Future<UserResponse> updateUserInfo(
  String description,
  String profilePicture,
  bool newPicture,
  File? file,
    String formerImage,
) async {
  String token = await getCurrentUserToken();
  String username = await getCurrentUsername();
  late http.Response response;
  String path = "/user/info";

  try {
    log("NEW PICTURE : $newPicture");
    if (newPicture) {
      final minio = Minio(
        endPoint: 's3.amazonaws.com',
        accessKey: AWS_ACCESSKEY,
        secretKey: AWS_SECRETKEY,
        region: AWSRegions.euWest3.region,
      );

      await minio.removeObject(AWS_BUCKETNAME, formerImage);
      final encryptedFileName = utf8.fuse(base64).encode(username + file!.path);
      await minio.fPutObject(AWS_BUCKETNAME,
          'uploads/$username/$encryptedFileName.png', file.path);
      profilePicture = '$AWS_URL/uploads/$username/$encryptedFileName.png';
    }

    Map data = {
      "description": description,
      "profilePicture": profilePicture,
    };

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
      UserResponse data = UserResponse.fromJsonData(json.decode(response.body));
      return data;
    } catch (e) {
      print("ERREUR");
      print(e);
    }
    log(response.body);
    return UserResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message'],
        payload: null);
  } else {
    return UserResponse(
        code: json.decode(response.body)['code'],
        message: json.decode(response.body)['message'],
        payload: null);
  }
}
