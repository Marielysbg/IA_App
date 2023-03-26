class ApiModel {

  final String id;
  final int created;
  final String root;

  ApiModel({
    required this.id, 
    required this.created, 
    required this.root
  });

  factory ApiModel.fromJson(Map<String, dynamic> json) => 
  ApiModel(
    id: json["id"], 
    created: json["created"], 
    root: json["root"]
    );

    static List<ApiModel> modelsFromSnapshot(List modelSnapshot){
      return modelSnapshot.map((data) => ApiModel.fromJson(data)).toList();
    }
}