import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:minio/io.dart';
import 'package:minio/minio.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/response/baseresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';
import 'package:simple_s3/simple_s3.dart';

Future<BasicResponse> createPug(
    File file,
    String title,
    String imageDescription,
    List<PugDetailModel> details,
    bool isCrop,
    int height) async {
  String token = await getCurrentUserToken();
  String username = await getCurrentUsername();

  var response;
  const String path = "/pug/add";

  try {
    final minio = Minio(
      endPoint: 's3.amazonaws.com',
      accessKey: AWS_ACCESSKEY,
      secretKey: AWS_SECRETKEY,
      region: AWSRegions.euWest3.region,
    );

    final encryptedFileName = utf8.fuse(base64).encode(username + file.path);
    await minio.fPutObject(
        AWS_BUCKETNAME, 'uploads/' + encryptedFileName + '.png', file.path);
    final imageUrl = "$AWS_URL/uploads/" + encryptedFileName + '.png';

    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': 'Bearer ' + token
    };
    print(details.length);
    print(json.encode(details.map((e) => e.toJson()).toList()));
    var formData = {
      "details": details.map((e) => e.toJson()).toList(),
      "imageDescription": imageDescription,
      "imageTitle": title,
      "isCrop": isCrop,
      "height": height,
      "imageUrl": imageUrl
    };

    Dio dio = Dio();
    dio.options.headers.addAll(headers);
    response = await dio.post(URL + path, data: formData);
  } catch (e) {
    print(e.toString());
    return BasicResponse(code: 1, message: "Erreur", payload: null);
  }

  if (response.statusCode == 201) {
    var data = BasicResponse(
        code: response.data['code'],
        message: response.data['message'],
        payload: null);
    return data;
  } else {
    return BasicResponse(
        code: 1, message: response.data['message'], payload: null);
  }
}
