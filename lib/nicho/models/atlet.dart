import 'dart:convert';

List<AtletList> atletListFromJson(String str) =>
    List<AtletList>.from(json.decode(str).map((x) => AtletList.fromJson(x)));

String atletListToJson(List<AtletList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AtletList {
  int pk;
  String name;
  String shortName;
  String discipline;
  String country;
  bool isVisible;
  int goldCount;
  int silverCount;
  int bronzeCount;
  int totalMedals;

  AtletList({
    required this.pk,
    required this.name,
    required this.shortName,
    required this.discipline,
    required this.country,
    required this.isVisible,
    required this.goldCount,
    required this.silverCount,
    required this.bronzeCount,
    required this.totalMedals,
  });

  factory AtletList.fromJson(Map<String, dynamic> json) => AtletList(
    pk: json["pk"],
    name: json["name"],
    shortName: json["short_name"] ?? "",
    discipline: json["discipline"] ?? "General",
    country: json["country"],
    isVisible: json["is_visible"],
    goldCount: json["gold_count"],
    silverCount: json["silver_count"],
    bronzeCount: json["bronze_count"],
    totalMedals: json["total_medals"],
  );

  Map<String, dynamic> toJson() => {
    "pk": pk,
    "name": name,
    "short_name": shortName,
    "discipline": discipline,
    "country": country,
    "is_visible": isVisible,
    "gold_count": goldCount,
    "silver_count": silverCount,
    "bronze_count": bronzeCount,
    "total_medals": totalMedals,
  };
}
