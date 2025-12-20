// To parse this JSON data, do
//
//     final newsEntry = newsEntryFromJson(jsonString);

import 'dart:convert';

List<NewsEntry> newsEntryFromJson(String str) => List<NewsEntry>.from(json.decode(str).map((x) => NewsEntry.fromJson(x)));

String newsEntryToJson(List<NewsEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsEntry {
    int id;
    String title;
    String content;
    Category category;
    CategoryDisplay categoryDisplay;
    String? thumbnail;
    Author author;
    DateTime createdAt;
    dynamic? cabangOlahraga;

    NewsEntry({
        required this.id,
        required this.title,
        required this.content,
        required this.category,
        required this.categoryDisplay,
        this.thumbnail,
        required this.author,
        required this.createdAt,
        this.cabangOlahraga,
    });

    factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        category: categoryValues.map[json["category"]]!,
        categoryDisplay: categoryDisplayValues.map[json["category_display"]]!,
        thumbnail: json["thumbnail"],
        author: authorValues.map[json["author"]]!,
        createdAt: DateTime.parse(json["created_at"]),
        cabangOlahraga: json["cabangOlahraga"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "category": categoryValues.reverse[category],
        "category_display": categoryDisplayValues.reverse[categoryDisplay],
        "thumbnail": thumbnail,
        "author": authorValues.reverse[author],
        "created_at": createdAt.toIso8601String(),
        "cabangOlahraga": cabangOlahraga,
    };
}

enum Author {
    DELILA,
    DELILA_ISRINA
}

final authorValues = EnumValues({
    "delila": Author.DELILA,
    "delila.isrina": Author.DELILA_ISRINA
});

enum Category {
    ATHLETE,
    EVENT,
    MEDAL,
    OTHER
}

final categoryValues = EnumValues({
    "athlete": Category.ATHLETE,
    "event": Category.EVENT,
    "medal": Category.MEDAL,
    "other": Category.OTHER
});

enum CategoryDisplay {
    ATHLETE_STORY,
    EVENT,
    MEDAL_RESULT,
    OTHER
}

final categoryDisplayValues = EnumValues({
    "Athlete Story": CategoryDisplay.ATHLETE_STORY,
    "Event": CategoryDisplay.EVENT,
    "Medal Result": CategoryDisplay.MEDAL_RESULT,
    "Other": CategoryDisplay.OTHER
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
