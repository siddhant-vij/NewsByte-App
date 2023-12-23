import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:newsbyte/utils/constants.dart';

class FetchNewsArticlesService {
  final String newsApiKey;

  FetchNewsArticlesService(this.newsApiKey);

  Future<List<String>> fetchDataSourcesFromTopHeadlines() async {
    final prefs = await SharedPreferences.getInstance();

    // Check for cached data and its timestamp
    final cachedData = prefs.getString('cachedSources');
    final lastFetchTime = prefs.getInt('lastFetchTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const oneDayMillis = 24 * 60 * 60 * 1000;

    // Return cached data if it's less than a day old
    if (cachedData != null && currentTime - lastFetchTime < oneDayMillis) {
      return List<String>.from(json.decode(cachedData));
    }

    // Fetch new data if cache is outdated or not present
    return await _fetchAndCacheDataSources(prefs);
  }

  Future<List<String>> _fetchAndCacheDataSources(
      SharedPreferences prefs) async {
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
      List<String> sources = (data['sources'] as List)
          .map((source) => source['id'].toString())
          .toList();
      // Cache the fetched data along with the current timestamp
      await prefs.setString('cachedSources', json.encode(sources));
      await prefs.setInt(
          'lastFetchTime', DateTime.now().millisecondsSinceEpoch);
      return sources;
    } else {
      throw Exception('Failed to load data sources');
    }
  }

  Stream<Map<String, dynamic>> fetchNewsArticles(
      {int page = 1, int pageSize = 20, int maxArticlesPerSource = 2}) async* {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $newsApiKey',
    };

    List<String> sources = await fetchDataSourcesFromTopHeadlines();
    Map<String, int> articleCountPerSource = {};
    Random random = Random();

    while (true) {
      String selectedSource = sources[random.nextInt(sources.length)];

      int count = articleCountPerSource[selectedSource] ?? 0;
      if (count >= maxArticlesPerSource) {
        continue;
      }

      String url =
          '$everythingEndpoint?language=en&sources=$selectedSource&pageSize=$pageSize&page=$page';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> articles =
            (data['articles'] as List<dynamic>).cast<Map<String, dynamic>>();

        for (var article in articles) {
          if (article['urlToImage'] != null &&
              article['urlToImage'].toString().isNotEmpty) {
            yield article;
            articleCountPerSource[selectedSource] = count + 1;
            if (articleCountPerSource[selectedSource] == maxArticlesPerSource) {
              break;
            }
          }
        }
      } else {
        throw Exception(
            'Failed to load news articles because of ${response.statusCode}');
      }
    }
  }
}
