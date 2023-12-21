// ignore_for_file: unnecessary_getters_setters

import 'dart:io';

class NewsArticle {
  String _sourceName;
  String _url;
  String _title;
  String _description;
  DateTime _publishedAt;
  File _imageFilePath;

  NewsArticle({
    required String sourceName,
    required String url,
    required String title,
    required String description,
    required DateTime publishedAt,
    required File imageFilePath,
  })  : _sourceName = sourceName,
        _url = url,
        _title = title,
        _description = description,
        _publishedAt = publishedAt,
        _imageFilePath = imageFilePath;

  // Getters
  String get sourceName => _sourceName;
  String get url => _url;
  String get title => _title;
  String get description => _description;
  DateTime get publishedAt => _publishedAt;
  File get imageFilePath => _imageFilePath;

  // Setters
  set sourceName(String value) => _sourceName = value;
  set url(String value) => _url = value;
  set title(String value) => _title = value;
  set description(String value) => _description = value;
  set publishedAt(DateTime value) => _publishedAt = value;
  set imageFilePath(File value) => _imageFilePath = value;

  // JSON serialization
  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
        sourceName: json['sourceName'],
        url: json['url'],
        title: json['title'],
        description: json['description'],
        publishedAt: DateTime.parse(json['publishedAt']),
        imageFilePath: json['imageFilePath'],
      );

  Map<String, dynamic> toJson() => {
        'sourceName': sourceName,
        'url': url,
        'title': title,
        'description': description,
        'publishedAt': publishedAt.toIso8601String(),
        'imageFilePath': imageFilePath,
      };
}
