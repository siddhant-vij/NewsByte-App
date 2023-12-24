import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:newsbyte/models/news_article.dart';
import 'package:newsbyte/services/content_summarization.dart';
import 'package:newsbyte/services/fetch_news_articles.dart';
import 'package:newsbyte/services/image_optimization.dart';
import 'package:newsbyte/utils/constants.dart';

class AggregationService {
  final FetchNewsArticlesService fetchNewsArticlesService;
  final ContentSummarizationService contentSummarizationService;
  final ImageOptimizationService imageOptimizationService;

  final List<String> _recentArticleUrls = [];

  AggregationService(
    this.fetchNewsArticlesService,
    this.contentSummarizationService,
    this.imageOptimizationService,
  );

  List<String> getRecentArticleUrls() {
    return _recentArticleUrls;
  }

  Stream<NewsArticle> aggregateArticlesStream(int page, int pageSize) async* {
    var processingFutures = <Future<NewsArticle?>>[];

    await for (var articleData in fetchNewsArticlesService.fetchNewsArticles(
        page: page, pageSize: pageSize)) {
      processingFutures.add(processArticle(articleData));

      if (processingFutures.length == articlesFetchedAtATime) {
        var articles = await Future.wait(processingFutures);
        _updateRecentArticlesList(articles);
        yield* Stream.fromIterable(
            articles.where((article) => article != null).cast<NewsArticle>());
        processingFutures.clear();
      }
    }

    if (processingFutures.isNotEmpty) {
      var articles = await Future.wait(processingFutures);
      _updateRecentArticlesList(articles);
      yield* Stream.fromIterable(
          articles.where((article) => article != null).cast<NewsArticle>());
    }
  }

  Future<NewsArticle?> processArticle(Map<String, dynamic> articleData) async {
    try {
      String title = articleData['title'];
      String combinedDescriptionAndContent =
          articleData['description'] + " " + articleData['content'];

      String summarizedTitle = await contentSummarizationService
          .summarizeContent(title, titleLength);
      String summarizedDescription = await contentSummarizationService
          .summarizeContent(combinedDescriptionAndContent, descriptionLength);
      File optimizedImagePath = await imageOptimizationService
          .optimizeImage(articleData['urlToImage']);

      return NewsArticle(
        sourceName: articleData['source']['name'] as String,
        url: articleData['url'] as String,
        title: summarizedTitle,
        description: summarizedDescription,
        publishedAt: DateTime.parse(articleData['publishedAt']),
        author: articleData['author'] as String,
        imageFilePath: optimizedImagePath,
      );
    } catch (e) {
      // Log error
      return null; // Consider handling this more gracefully
    }
  }

  void _updateRecentArticlesList(List<NewsArticle?> articles) {
    for (var article in articles) {
      if (article != null) {
        _recentArticleUrls.add(article.url);
        _cacheArticle(article);
      }
    }
  }

  Future<void> _cacheArticle(NewsArticle article) async {
    String key = article.url;
    String jsonData = json.encode(article.toJson());
    await DefaultCacheManager().putFile(
      key,
      Uint8List.fromList(jsonData.codeUnits),
      fileExtension: 'json',
    );
  }
}
