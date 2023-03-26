import 'dart:collection';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
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

  //Envio de mensajes
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
   
    final newMessage = ChatModel(msg: text, chatIndex: 1, fromWho: FromWho.me);
    await saveChat(newMessage);
   
    messageList.add(newMessage);

    //Enviamos el mensaje del usuario al bot
    otherReply(text);
    notifyListeners();
    moveScrollToBottom();

  }

  //Respuesta de la API
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

//Scroll al final de la ventana
 Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));

    chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

// Convertimos el texto a speech
  Future<void> textToSpeech(String text) async{
      await ftts.speak(text);
  }

//Inicio de sesión anónimo con firebase (así obtenemos un userId sin autenticación real)
  Future<void> signInAnonymously() async{
    try {

      //Obtenemos una instancia del signIn
     UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();

     //Obtenemos el UUID
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

//Método para guardar chats en la bd
  Future<void> saveChat(ChatModel chatModel) async{
    //Obtenemos una instancia de la bd
      DatabaseReference ref = FirebaseDatabase.instance.ref("chat/$uuid/");

      //Parseamos el modelo a json
      Map<String, dynamic> jsonData = chatModel.toJson();

      //Parseamos el json al modelo de la bd
      Map<String, dynamic> newMessage = DbModel.fromJson(jsonData).toJson();
      
      //Seteamos el mensaje en la bd
      await ref.push().set(newMessage);
  }

//Método para obtener chats de la bd
Future<void> getChat() async{
   //Obtenemos una instancia de la bd
  final ref = FirebaseDatabase.instance.ref();

  //Ingresamos al child perteneciente al UUID del usuario 
  final snapshot = await ref.child('chat').child("$uuid").get();
  if (snapshot.exists) {
    if(snapshot.child('$uuid').value !=null) {
      Map chat = snapshot.child('$uuid').value as Map;

        //Ordenamos el MAP por fecha
        final sortedMapA = SplayTreeMap<String, dynamic>.from(chat);

        //Cargamos la lista con los mensajes nuevos
        for (var element in sortedMapA.values) {

          //Obtenemos el enum por value
          FromWho f = FromWho.values.firstWhere((e) => e.toString() == 'FromWho.${element["fromWho"]}');
          final newMessage = ChatModel(msg: element["msg"], chatIndex: 1, fromWho: f);

          //Cargamos el model en la lista
          messageList.add(newMessage);
        }


        notifyListeners();
        moveScrollToBottom();
      }
  } 
}
  
}
