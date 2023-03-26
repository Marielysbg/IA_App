import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:yes_no/config/helpers/api_services.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yes_no/presentation/providers/chat_provider.dart';

class AudioRecorder extends StatefulWidget {
  final ValueChanged<String> onValue2;
  const AudioRecorder({super.key, required this.onValue2});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {

  ApiService apiService = ApiService();
  

  String statusText = "";
  bool isComplete = false;
  bool buttonStatus = false;

  



  @override
  Widget build(BuildContext context) {
     final chatProvider = context.watch<ChatProvider>();
     
    return IconButton(
      onPressed: () async {
        if( buttonStatus ){
           print('STOP recording');
          await stopRecord();
          await play();
        } else {
          print('start recording');
          await startRecord();
        }

        setState(() {});
      }, 
      icon: Icon(buttonStatus ? Icons.mic : Icons.mic_off)
    );
  }


   Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

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


  stopRecord() async {
    bool s = RecordMp3.instance.stop();
    if (s) {
      statusText = "Record complete";
      isComplete = true;
      buttonStatus = false;
      setState(() {});
    }


    print("path $recordFilePath");
   
   
  }

  // void resumeRecord() {
  //   bool s = RecordMp3.instance.resume();
  //   if (s) {
  //     statusText = "Recording...";
  //     setState(() {});
  //   }
  // }

  String recordFilePath = '';

  // void play() {
  //   if (recordFilePath != null && File(recordFilePath).existsSync()) {
  //     AudioPlayer audioPlayer = AudioPlayer();
  //     audioPlayer.play(recordFilePath, isLocal: true);
  //   }
  // }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }

    return sdPath + "/test_${i++}.mp3";
  }

   play() async{
    if (recordFilePath != '' && File(recordFilePath).existsSync()) {
      File file2 = File(recordFilePath);
       String response = await apiService.sendRecord(path: recordFilePath, file: file2);
        widget.onValue2(response);
    }
  }

}