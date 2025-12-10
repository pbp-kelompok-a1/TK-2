import 'dart:convert';

// Use this function if your API returns a LIST of users
List<CustomUser> customUserListFromJson(String str) =>
    List<CustomUser>.from(json.decode(str).map((x) => CustomUser.fromJson(x)));

// Use this function if your API returns a SINGLE user object
CustomUser customUserFromJson(String str) =>
    CustomUser.fromJson(json.decode(str));

String customUserToJson(CustomUser data) => json.encode(data.toJson());

class CustomUser {
  final String uuid;
  final int userId; // Matches the 'user' OneToOneField (User ID)
  final DateTime joinDate;
  final String username;
  final String? name;    // Nullable in Django
  final String? picture; // Nullable in Django

  CustomUser({
    required this.uuid,
    required this.userId,
    required this.joinDate,
    required this.username,
    this.name,
    this.picture,
  });

  factory CustomUser.fromJson(Map<String, dynamic> json) => CustomUser(
    uuid: json["uuid"],
    userId: json["user"], // Django PK usually comes as "user"
    joinDate: DateTime.parse(json["join_date"]),
    username: json["username"],
    name: json["name"], // Can be null
    picture: json["picture"], // Can be null or URL string
  );

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "user": userId,
    "join_date": joinDate.toIso8601String(),
    "username": username,
    "name": name,
    "picture": picture,
  };
}