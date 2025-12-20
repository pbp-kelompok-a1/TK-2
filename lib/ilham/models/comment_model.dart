import 'dart:convert';

List<CommentModel> commentModelFromJson(String str) => List<CommentModel>.from(json.decode(str).map((x) => CommentModel.fromJson(x)));

String commentModelToJson(List<CommentModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CommentModel {
    int id;
    String user;
    String content;
    bool isEdited;
    String date;
    bool isOwner;
    bool canDelete;

    CommentModel({
        required this.id,
        required this.user,
        required this.content,
        required this.isEdited,
        required this.date,
        required this.isOwner,
        required this.canDelete,
    });

    factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json["id"],
        user: json["user"],
        content: json["content"],
        isEdited: json["is_edited"],
        date: json["date"],
        isOwner: json["is_owner"],
        canDelete: json["can_delete"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "content": content,
        "is_edited": isEdited,
        "date": date,
        "is_owner": isOwner,
        "can_delete": canDelete,
    };
}
