import 'package:flutter/material.dart';
import 'package:yes_no/config/helpers/api_services.dart';
import 'package:yes_no/infrastructure/models/chat_model.dart';


class ChatProvider extends ChangeNotifier {
  final chatScrollController = ScrollController();

  final ApiService apiService = ApiService();

  List<ChatModel> messageList = [];

  bool isTyping = false;

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
   
    final newMessage = ChatModel(msg: text, chatIndex: 1, fromWho: FromWho.me);
   
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
    notifyListeners();
    moveScrollToBottom();

  }

 Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));

    chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }
  
}
