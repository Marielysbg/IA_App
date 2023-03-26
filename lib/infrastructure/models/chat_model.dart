enum FromWho { me, otherPerson }

class ChatModel {
  
  final String msg;
  final int chatIndex;
  final FromWho fromWho;

  ChatModel({
    required this.msg, 
    required this.chatIndex,
    required this.fromWho
  });

    factory ChatModel.fromJson(Map<String, dynamic> json) => 
    ChatModel(
      msg: json["msg"], 
      chatIndex: json["chatIndex"],
      fromWho: FromWho.otherPerson
    );

}