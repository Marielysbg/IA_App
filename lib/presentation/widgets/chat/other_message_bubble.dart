import 'package:flutter/material.dart';
import 'package:yes_no/infrastructure/models/chat_model.dart';

class OtherMessageBuble extends StatelessWidget {
  //final Message message;
  final ChatModel message;
  const OtherMessageBuble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 10, maxWidth: 270),
          decoration: BoxDecoration(
              color: colors.secondary, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              message.msg,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        
      ],
    );
  }
}

