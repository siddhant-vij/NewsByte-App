import 'dart:io';

import 'package:flutter/foundation.dart';

@immutable
class NewsArticle {
  final String sourceName;
  final String url;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String author;
  final File imageFilePath;

  const NewsArticle({
    required this.sourceName,
    required this.url,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.author,
    required this.imageFilePath,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
        sourceName: json['sourceName'],
        url: json['url'],
        title: json['title'],
        description: json['description'],
        publishedAt: DateTime.parse(json['publishedAt']),
        author: json['author'],
        imageFilePath: File(json['imageFilePath']),
      );

  Map<String, dynamic> toJson() => {
        'sourceName': sourceName,
        'url': url,
        'title': title,
        'description': description,
        'publishedAt': publishedAt.toIso8601String(),
        'author': author,
        'imageFilePath': imageFilePath.path,
      };

  @override
  String toString() {
    return 'NewsArticle{\n'
        'sourceName: $sourceName,\n'
        'url: $url,\n'
        'title: $title,\n'
        'description: $description,\n'
        'publishedAt: ${publishedAt.toIso8601String()},\n'
        'author: $author,\n'
        'imageFilePath: ${imageFilePath.path},\n'
        '}';
  }
}
