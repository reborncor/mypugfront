import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:minio/minio.dart';
import 'package:simple_s3/simple_s3.dart';


import '../../response/BaseResponse.dart';
import '../../util/config.dart';
import '../../util/util.dart';


Future<BasicResponse> deleteAccount(String formerImage) async {
  String token = await getCurrentUserToken();
  late http.Response response;
  String path = "/user/delete";
  try {
    var url = Uri.parse(URL + path);
    response = await http.delete(url,
        headers: {
          "Content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
        );
  } catch (e) {
    print(e.toString());

    return json.decode(response.body);
  }

  if (response.statusCode == 200) {
    print(response.contentLength);

    try {
        final minio = Minio(
          endPoint: 's3.amazonaws.com',
          accessKey: AWS_ACCESSKEY,
          secretKey: AWS_SECRETKEY,
          region: AWSRegions.euWest3.region,
        );
        await minio.removeObject(AWS_BUCKETNAME, formerImage);


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

