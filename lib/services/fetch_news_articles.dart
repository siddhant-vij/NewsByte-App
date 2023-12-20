import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:newsbyte/utils/constants.dart';

class FetchNewsArticlesService {
  final String newsApiKey;

  FetchNewsArticlesService(this.newsApiKey);

  Future<List<String>> fetchDataSourcesFromTopHeadlines() async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $newsApiKey',
    };
    const String url = '$topHeadlinesEndpoint/sources?language=en';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return (data['sources'] as List<dynamic>)
          .map((source) => source['id'].toString())
          .toList();
    } else {
      throw Exception('Failed to load data sources');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNewsArticles() async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $newsApiKey',
    };
    List<String> sources = await fetchDataSourcesFromTopHeadlines();
    final String url =
        '$everythingEndpoint?language=en&sortBy=popularity&sources=${sources.join(',')}';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return (data['articles'] as List<dynamic>).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load news articles');
    }
  }
}
