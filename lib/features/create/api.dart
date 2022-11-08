import 'dart:convert';
import 'dart:io';



import 'package:dio/dio.dart';
import 'package:http/http.dart'as http;
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/response/baseresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';

import 'dart:async';

Future<BasicResponse> createPug(File file,String title, String imageDescription,List<PugDetailModel> details, bool isCrop, int height) async{

  String token = await getCurrentUserToken();
  String username = await getCurrentUsername();
  var response;
  const String path = "/pug/add";

  try {

    Map<String, String> headers = { "Content-type": "application/json",'Authorization': 'Bearer '+ token};
    print(details.length);
    print(json.encode(details.map((e) => e.toJson()).toList()));
    var formData = FormData.fromMap({
      "newimage": await MultipartFile.fromFile(file.path, filename: username),
      "details": details.map((e) => e.toJson()).toList(),
      "imageDescription" : imageDescription,
      "imageTitle" : title,
      "isCrop" : isCrop,
      "height" : height,
    });


    Dio dio = Dio();
    dio.options.headers.addAll(headers);
    response = await dio.post(URL+path, data: formData);
    // print(response.statusCode);
    // print(response.data['message']);
  }
  catch (e) {
    print(e.toString());
    return  BasicResponse(code: 1, message: "Erreur", payload: null);
  }

  if(response.statusCode == 201) {
    var data = BasicResponse(code: response.data['code'], message: response.data['message'], payload: null);
    return data ;
  }
  else{
    return BasicResponse(code: 1, message: response.data['message'], payload: null);
  }


}
