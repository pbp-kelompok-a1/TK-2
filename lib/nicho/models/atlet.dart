// To parse this JSON data, do
//
//     final atletList = atletListFromJson(jsonString);

import 'dart:convert';

List<AtletList> atletListFromJson(String str) =>
    List<AtletList>.from(json.decode(str).map((x) => AtletList.fromJson(x)));

String atletListToJson(List<AtletList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AtletList {
  int pk;
  String name;
  String shortName;
  Discipline discipline;
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
    shortName: json["short_name"],
    discipline: disciplineValues.map[json["discipline"]]!,
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
    "discipline": disciplineValues.reverse[discipline],
    "country": country,
    "is_visible": isVisible,
    "gold_count": goldCount,
    "silver_count": silverCount,
    "bronze_count": bronzeCount,
    "total_medals": totalMedals,
  };
}

enum Discipline {
  CYCLING_ROAD,
  CYCLING_TRACK,
  EQUESTRIAN,
  OTHER,
  POWERLIFTING,
  SITTING_VOLLEYBALL,
  SWIMMING,
  TENNIS,
  WHEELCHAIR_FENCING,
}

final disciplineValues = EnumValues({
  "Cycling Road": Discipline.CYCLING_ROAD,
  "Cycling Track": Discipline.CYCLING_TRACK,
  "Equestrian": Discipline.EQUESTRIAN,
  "Other": Discipline.OTHER,
  "Powerlifting": Discipline.POWERLIFTING,
  "Sitting Volleyball": Discipline.SITTING_VOLLEYBALL,
  "Swimming": Discipline.SWIMMING,
  "Tennis": Discipline.TENNIS,
  "Wheelchair Fencing": Discipline.WHEELCHAIR_FENCING,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
