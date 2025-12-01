import 'dart:convert';

Following followingFromJson(String str) => Following.fromJson(json.decode(str));

String followingToJson(Following data) => json.encode(data.toJson());

class Following {
  List<FollowingElement> followings;

  Following({
    required this.followings,
  });

  factory Following.fromJson(Map<String, dynamic> json) => Following(
    followings: List<FollowingElement>.from(json["followings"].map((x) => FollowingElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "followings": List<dynamic>.from(followings.map((x) => x.toJson())),
  };
}

class FollowingElement {
  String id;
  int user;
  String cabangOlahraga;

  FollowingElement({
    required this.id,
    required this.user,
    required this.cabangOlahraga,
  });

  factory FollowingElement.fromJson(Map<String, dynamic> json) => FollowingElement(
    id: json["id"],
    user: json["user"],
    cabangOlahraga: json["cabangOlahraga"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user,
    "cabangOlahraga": cabangOlahraga,
  };
}