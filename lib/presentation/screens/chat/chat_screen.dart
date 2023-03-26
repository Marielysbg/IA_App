import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yes_no/infrastructure/models/chat_model.dart';
import 'package:yes_no/presentation/providers/chat_provider.dart';
import 'package:yes_no/presentation/widgets/chat/my_message_buble.dart';
import 'package:yes_no/presentation/widgets/chat/other_message_bubble.dart';
import 'package:yes_no/presentation/widgets/shared/message_field_box.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5j1QoysD2S9Mq32jDCO9ExkcKWP19RbcDxA&usqp=CAU"),
          ),
        ),
        title: const Text("Joy", style: TextStyle(fontSize: 20)),
      ),
      body: _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
     final colors = Theme.of(context).colorScheme;
    

    return SafeArea(
      // ignore: avoid_unnecessary_containers
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(children: [
            const SizedBox(height: 5),
            Expanded(
                child: ListView.builder(
                controller: chatProvider.chatScrollController,
              itemCount: chatProvider.messageList.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messageList[index];
                return (message.fromWho == FromWho.otherPerson)
                    ? OtherMessageBuble(message: message,)
                    : MyMesaggeBuble(message: message);
              },
            )),
            chatProvider.isTyping ? SpinKitThreeBounce(
                color: colors.secondary,
                size: 18,
              ) : Container(),
        
            //Caja de texto de mensajes
            MessageFieldBox(
              onValue:  chatProvider.sendMessage,
            )
          ]),
        ),
      ),
    );
  }
}
