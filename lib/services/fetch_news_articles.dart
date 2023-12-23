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
    return await _getCachedSources(prefs) ??
        await _fetchAndCacheDataSources(prefs);
  }

  Future<List<String>?> _getCachedSources(SharedPreferences prefs) async {
    final cachedData = prefs.getString('cachedSources');
    final lastFetchTime = prefs.getInt('lastFetchTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const oneDayMillis = 24 * 60 * 60 * 1000;

    if (cachedData != null && currentTime - lastFetchTime < oneDayMillis) {
      return List<String>.from(json.decode(cachedData));
    }
    return null;
  }

  Future<List<String>> _fetchAndCacheDataSources(
      SharedPreferences prefs) async {
    final response = await http.get(
        Uri.parse('$topHeadlinesEndpoint/sources?language=en'),
        headers: _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final sources = (data['sources'] as List)
          .map((source) => source['id'].toString())
          .toList();
      await _cacheSourcesData(prefs, sources);
      return sources;
    } else {
      throw Exception('Failed to load data sources');
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $newsApiKey'
    };
  }

  Future<void> _cacheSourcesData(
      SharedPreferences prefs, List<String> sources) async {
    await prefs.setString('cachedSources', json.encode(sources));
    await prefs.setInt('lastFetchTime', DateTime.now().millisecondsSinceEpoch);
  }

  Stream<Map<String, dynamic>> fetchNewsArticles(
      {int page = 1, int pageSize = 1, int maxArticlesPerSource = 2}) async* {
    final sources = await fetchDataSourcesFromTopHeadlines();
    final articleCountPerSource = <String, int>{};
    final random = Random();

    while (true) {
      final selectedSource = sources[random.nextInt(sources.length)];

      if (_isExceedingArticleLimit(
          articleCountPerSource, selectedSource, maxArticlesPerSource)) {
        continue;
      }

      final articles =
          await _fetchArticlesFromSource(selectedSource, pageSize, page);
      if (articles.isNotEmpty) {
        yield* Stream.fromIterable(articles);
        articleCountPerSource.update(selectedSource, (count) => count + 1,
            ifAbsent: () => 1);
      }

      if (articles.length < pageSize) break;
      page++;
    }
  }

  bool _isExceedingArticleLimit(
      Map<String, int> articleCountPerSource, String source, int limit) {
    return (articleCountPerSource[source] ?? 0) >= limit;
  }

  Future<List<Map<String, dynamic>>> _fetchArticlesFromSource(
      String source, int pageSize, int page) async {
    final url =
        '$everythingEndpoint?language=en&sources=$source&pageSize=$pageSize&page=$page';
    final response = await http.get(Uri.parse(url), headers: _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['articles'] as List)
          .cast<Map<String, dynamic>>()
          .where((article) =>
              article['urlToImage'] != null &&
              article['urlToImage'].toString().isNotEmpty)
          .toList();
    } else {
      throw Exception('Failed to load news articles: ${response.statusCode}');
    }
  }
}
