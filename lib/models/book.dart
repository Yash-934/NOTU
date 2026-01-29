import 'dart:convert';

class Book {
  final int? id;
  final String title;
  final String? thumbnail;

  Book({this.id, required this.title, this.thumbnail});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      thumbnail: map['thumbnail'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Book.fromJson(String source) {
    final map = json.decode(source);
    if (map is Map<String, dynamic>) {
      return Book.fromMap(map);
    }
    // If the JSON is a list (from the backup), handle that case too,
    // although it's not ideal for a single book import.
    if (map is List && map.isNotEmpty && map.first is Map<String, dynamic>) {
      return Book.fromMap(map.first);
    }
    throw const FormatException('Invalid JSON format for Book');
  }
}
