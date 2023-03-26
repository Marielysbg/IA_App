import 'dart:collection';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:yes_no/config/helpers/api_services.dart';
import 'package:yes_no/infrastructure/models/chat_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:yes_no/infrastructure/models/db_model.dart';


class ChatProvider extends ChangeNotifier {

  final chatScrollController = ScrollController();
  FlutterTts ftts = FlutterTts();
  final ApiService apiService = ApiService();
  String? uuid = '';

  List<ChatModel> messageList = [];
  bool isTyping = false;

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
   
    final newMessage = ChatModel(msg: text, chatIndex: 1, fromWho: FromWho.me);
    await saveChat(newMessage);
   
    messageList.add(newMessage);

    otherReply(text);
    notifyListeners();
    moveScrollToBottom();

  }

  Future<void> otherReply(String text) async {
    isTyping = true;
    final otherMessage = await apiService.sendMessage(message: text);
     isTyping = false;
    messageList.add(otherMessage);
       await saveChat(otherMessage);
    notifyListeners();
    moveScrollToBottom();
    await textToSpeech(otherMessage.msg);
  }

 Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));

    chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  Future<void> textToSpeech(String text) async{
      
      await ftts.speak(text);

  }

  Future<void> signInAnonymously() async{
    try {
     UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
     uuid = userCredential.user?.uid;
      log("Signed in with temporary account.");
  
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          log("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          log("Unknown error.");
      }
      rethrow;
  }
  }

  Future<void> saveChat(ChatModel chatModel) async{
      DatabaseReference ref = FirebaseDatabase.instance.ref("chat/$uuid/");


      Map<String, dynamic> jsonData = chatModel.toJson();
      Map<String, dynamic> newMessage = DbModel.fromJson(jsonData).toJson();
      
      await ref.push().set(newMessage);
  }

    Future<void> getChat() async{
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('chat').child("$uuid").get();
      if (snapshot.exists) {
        if(snapshot.child('$uuid').value !=null) {
          Map chat = snapshot.child('$uuid').value as Map;
           final sortedMapA = SplayTreeMap<String, dynamic>.from(chat);
            for (var element in sortedMapA.values) {
              FromWho f = FromWho.values.firstWhere((e) => e.toString() == 'FromWho.${element["fromWho"]}');
              final newMessage = ChatModel(msg: element["msg"], chatIndex: 1, fromWho: f);
              messageList.add(newMessage);
            }
            notifyListeners();
          }
      } 
  }
  
}
