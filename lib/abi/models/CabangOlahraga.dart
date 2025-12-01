import 'dart:convert';

CabangOlahraga cabangOlahragaFromJson(String str) => CabangOlahraga.fromJson(json.decode(str));

String cabangOlahragaToJson(CabangOlahraga data) => json.encode(data.toJson());

class CabangOlahraga {
  List<CabangOlahragaElement> cabangOlahraga;

  CabangOlahraga({
    required this.cabangOlahraga,
  });

  factory CabangOlahraga.fromJson(Map<String, dynamic> json) => CabangOlahraga(
    cabangOlahraga: List<CabangOlahragaElement>.from(json["cabangOlahraga"].map((x) => CabangOlahragaElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cabangOlahraga": List<dynamic>.from(cabangOlahraga.map((x) => x.toJson())),
  };
}

class CabangOlahragaElement {
  String id;
  String name;

  CabangOlahragaElement({
    required this.id,
    required this.name,
  });

  factory CabangOlahragaElement.fromJson(Map<String, dynamic> json) => CabangOlahragaElement(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}