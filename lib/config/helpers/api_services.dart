import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yes_no/config/helpers/constants.dart';
import 'package:http/http.dart' as http;
import 'package:yes_no/infrastructure/models/chat_model.dart';

class ApiService {

  final dio = Dio();

  //send message
   Future<ChatModel> sendMessage({required String message}) async {

      try {

         var response = await dio.post("$BASE_URL/chat/completions",
          data: jsonEncode({
              "model": "gpt-3.5-turbo",
              "messages": [{"role": "user", "content": message}],
              "temperature": 0.7
          }), 
          options: Options(
              headers: {
                    'Authorization': "Bearer $API_KEY",
                    'Content-Type': 'application/json'
                  }
              ));


        final newMessage = ChatModel(msg: response.data['choices'][0]['message']["content"], chatIndex: 1, fromWho: FromWho.otherPerson);

         return newMessage;
          

      } catch (error) {
        log("error1 $error");
        rethrow;
      }

  }

   Future<String> sendRecord({required String path, required File file}) async {

      try {


            FormData formData = FormData.fromMap({
              "model": "whisper-1",
              "file": await MultipartFile.fromFile(path),
            });
      
            var response = await dio.post("$BASE_URL/audio/transcriptions", data: formData, options:Options(
            headers: {
                  'Content-Length': file.lengthSync().toString(),
                  'Authorization': "Bearer $API_KEY"
                }
            ));

            return response.data['text'];

      } catch (error) {
        log("error1 $error");
        rethrow;
      }

  }

}