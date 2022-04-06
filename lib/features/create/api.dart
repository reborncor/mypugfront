import 'dart:convert';
import 'dart:io';



import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'as http;
import 'package:mypug/response/userpugresponse.dart';
import 'package:mypug/util/config.dart';
import 'package:mypug/util/util.dart';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';

Future<dynamic> createPug(File file) async{

  String token = await getCurrentUserToken();
  var response;
  const String path = "/pug/add";

  try {
    var url = Uri.parse(URL+path);
    // response = await http.get(url,
    //     headers: {"Content-type": "application/json",'Authorization': 'Bearer '+ token});

    // open a bytestream
    // var stream = http.ByteStream(file.openRead());
    // stream.cast();
    // // get file length
    // var length = await file.length();
    //
    // // string to uri
    // // var uri = Uri.parse("http://192.168.0.8:3000/upload");
    //
    // // create multipart request
    Map<String, String> headers = { "Content-type": "application/json",'Authorization': 'Bearer '+ token};
    //
    // var request = http.MultipartRequest("POST", url);
    // request.headers.addAll(headers);
    //
    // // multipart that takes file
    // var multipartFile = http.MultipartFile('newimage', stream, length,
    //     filename:file.path);
    //
    // // add file to multipart
    // request.files.add(multipartFile);
    // var response = await request.send();
    // print(response.statusCode);

    print("PATH : "+ file.path);
    String fileName = file.path.split('/').last;
    // print("NAME : "+ fileName);
    var formData = FormData.fromMap({
      "newimage": await MultipartFile.fromFile(file.path, filename: "new_file")
    });

    Dio dio = Dio();
    dio.options.headers.addAll(headers);
    var response = await dio.post(URL+path, data: formData);
  }
  catch (e) {
    print(e.toString());
    return json.decode(response.body);
  }

  if(response.statusCode == 200) {
    var data = UserPugResponse.fromJsonData(json.decode(response.body));
    return data ;
  }
  else{
    return UserPugResponse(code: json.decode(response.body)['code'], message: json.decode(response.body)['message']);
  }


}
