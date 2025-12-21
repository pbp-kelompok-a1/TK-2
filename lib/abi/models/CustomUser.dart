import 'dart:convert';

CustomUser userFromJson(String str) => CustomUser.fromJson(json.decode(str));

String userToJson(CustomUser data) => json.encode(data.toJson());

class CustomUser {
  List<User> users;

  CustomUser({
    required this.users,
  });

  factory CustomUser.fromJson(Map<String, dynamic> json) => CustomUser(
    users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "users": List<dynamic>.from(users.map((x) => x.toJson())),
  };
}

class User {
  int userId;
  String userUuid;
  String username;
  String name;
  String? picture;
  DateTime joinDate;

  User({
    required this.userId,
    required this.userUuid,
    required this.username,
    required this.name,
    required this.picture,
    required this.joinDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["user_id"],
    userUuid: json["user_uuid"],
    username: json["username"],
    name: json["name"],
    picture: json["picture"],
    joinDate: DateTime.parse(json["join_date"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "user_uuid": userUuid,
    "username": username,
    "name": name,
    "picture": picture,
    "join_date": joinDate.toIso8601String(),
  };
}
