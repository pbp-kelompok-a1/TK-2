import 'dart:convert';

CustomUser customUserFromJson(String str) => CustomUser.fromJson(json.decode(str));

String customUserToJson(CustomUser data) => json.encode(data.toJson());

class CustomUser {
  List<CustomUserElement> customUser;

  CustomUser({
    required this.customUser,
  });

  factory CustomUser.fromJson(Map<String, dynamic> json) => CustomUser(
    customUser: List<CustomUserElement>.from(json["customUser"].map((x) => CustomUserElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "customUser": List<dynamic>.from(customUser.map((x) => x.toJson())),
  };
}

class CustomUserElement {
  String uuid;
  int user;
  DateTime joinDate;
  String username;
  String name;
  dynamic picture;

  CustomUserElement({
    required this.uuid,
    required this.user,
    required this.joinDate,
    required this.username,
    required this.name,
    required this.picture,
  });

  factory CustomUserElement.fromJson(Map<String, dynamic> json) => CustomUserElement(
    uuid: json["uuid"],
    user: json["user"],
    joinDate: DateTime.parse(json["join_date"]),
    username: json["username"],
    name: json["name"],
    picture: json["picture"],
  );

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "user": user,
    "join_date": joinDate.toIso8601String(),
    "username": username,
    "name": name,
    "picture": picture,
  };
}
