class DbModel {
  
  final String msg;
  final String fromWho;
  final DateTime date;

  DbModel({
    required this.msg, 
    required this.fromWho,
    required this.date
  });

    factory DbModel.fromJson(Map<String, dynamic> json) => 
    DbModel(
      msg: json["msg"], 
      fromWho: json["fromWho"],
      date: DateTime.now()
    );

    Map<String, Object?> toJson() => {
      'msg': msg, 
      'date': DateTime.now().toString(),
      'fromWho': fromWho,

    };

}