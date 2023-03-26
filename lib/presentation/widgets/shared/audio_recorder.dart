import 'dart:io';


import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yes_no/config/helpers/api_services.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder extends StatefulWidget {
  final ValueChanged<String> onValue2;
  const AudioRecorder({super.key, required this.onValue2});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {

  //Instanciamos para obtener el método de speech-to-text
  ApiService apiService = ApiService();
  

  String statusText = "";
  bool isComplete = false;
  bool buttonStatus = false;


  @override
  Widget build(BuildContext context) {
     
    return IconButton(
      onPressed: () async {
        if( buttonStatus ){
          await stopRecord();
          await play();
        } else {
          await startRecord();
        }

        setState(() {});
      }, 
      icon: Icon(buttonStatus ? Icons.mic : Icons.mic_off)
    );
  }

    //Verificamos si el usuario aceptó los permisos para uso del micrófono
   Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  //Método que inicia la grabación del audio
  startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      statusText = "Recording...";
      recordFilePath = await getFilePath();
      isComplete = false;
      buttonStatus = true;
      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "Record error--->$type";
        setState(() {});
      });
    } else {
      statusText = "No microphone permission";
    }
    setState(() {});
  }

  //Método que finaliza la grabación del audio
  stopRecord() async {
    bool s = RecordMp3.instance.stop();
    if (s) {
      statusText = "Record complete";
      isComplete = true;
      buttonStatus = false;
      setState(() {});
    }
   
  }


  String recordFilePath = '';
  int i = 0;

  //Método para crear el path del audio
  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }

    return sdPath + "/test_${i++}.mp3";
  }

  //Método para enviar la grabación al api
   play() async{
    if (recordFilePath != '' && File(recordFilePath).existsSync()) {
      //Obtenemos el path del audio grabado
      File file2 = File(recordFilePath);

      //Se envia el path al API
       String response = await apiService.sendRecord(path: recordFilePath, file: file2);
        widget.onValue2(response);
    }
  }

}