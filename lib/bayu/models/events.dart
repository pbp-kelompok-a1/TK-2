// To parse this JSON data, do
//
//     final events = eventsFromJson(jsonString);

import 'dart:convert';

List<Events> eventsFromJson(String str) => List<Events>.from(json.decode(str).map((x) => Events.fromJson(x)));

String eventsToJson(List<Events> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Events {
  String id;
  String title;
  String description;
  String sportBranch;
  String location;
  String pictureUrl;
  DateTime startTime;
  DateTime? endTime;
  String eventType;
  int creatorId;
  String creatorName;
  String? cabangOlahraga;
  String? cabangOlahragaName;
  DateTime createdAt;

  Events({
    required this.id,
    required this.title,
    required this.description,
    required this.sportBranch,
    required this.location,
    required this.pictureUrl,
    required this.startTime,
    required this.endTime,
    required this.eventType,
    required this.creatorId,
    required this.creatorName,
    required this.cabangOlahraga,
    this.cabangOlahragaName,
    required this.createdAt,
  });

  factory Events.fromJson(Map<String, dynamic> json) => Events(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    sportBranch: json["sport_branch"],
    location: json["location"],
    pictureUrl: json["picture_url"],
    startTime: DateTime.parse(json["start_time"]),
    endTime: json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
    eventType: json["event_type"],
    creatorId: json["creator"] != null ? json["creator"]["id"] ?? 0 : 0,
    creatorName: json["creator"] != null ? json["creator"]["username"] ?? "Unknown" : "Unknown",
    cabangOlahraga: json["cabangOlahraga"]?.toString(),
    cabangOlahragaName: json["cabangOlahragaName"] ?? "General",
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "sport_branch": sportBranch,
    "location": location,
    "picture_url": pictureUrl,
    "start_time": startTime.toIso8601String(),
    "end_time": endTime?.toIso8601String(),
    "event_type": eventType,
    "creator": creatorId,
    "creatorName": creatorName,
    "cabangOlahraga": cabangOlahraga,
    "cabangOlahragaName": cabangOlahragaName,
    "created_at": createdAt.toIso8601String(),
  };
}
