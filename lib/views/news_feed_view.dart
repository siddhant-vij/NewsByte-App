import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:newsbyte/models/news_article.dart';
import 'package:newsbyte/services/aggregation_service.dart';
import 'package:newsbyte/services/api_config.dart';
import 'package:newsbyte/services/content_summarization.dart';
import 'package:newsbyte/services/fetch_news_articles.dart';
import 'package:newsbyte/services/image_optimization.dart';
import 'package:newsbyte/utils/cache_manager.dart';
import 'package:newsbyte/utils/constants.dart';
import 'package:newsbyte/widgets/news_card.dart';

class NewsFeedView extends StatefulWidget {
  const NewsFeedView({super.key});

  @override
  State<NewsFeedView> createState() => _NewsFeedViewState();
}

class _NewsFeedViewState extends State<NewsFeedView> {
  final List<NewsArticle> _articles = [];
  final int _maxArticlesCount = maxSizeOfDeque;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  int _currentPage = 1;
  bool _isInitialLoad = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    ApiConfig.loadConfig().then((_) {
      _loadArticlesFromCache();
    });
  }

  Future<void> _loadArticlesFromCache() async {
    final aggregationService = AggregationService(
      FetchNewsArticlesService(ApiConfig.newsApiKey),
      ContentSummarizationService(ApiConfig.summaryApiKey),
      ImageOptimizationService(),
    );

    var cachedUrls = aggregationService.getRecentArticleUrls();
    List<NewsArticle> cachedArticles = [];

    for (var url in cachedUrls) {
      var fileInfo = await CustomCacheManager.instance.getFileFromCache(url);
      if (fileInfo != null) {
        try {
          String content = await fileInfo.file.readAsString();
          NewsArticle article = NewsArticle.fromJson(json.decode(content));
          cachedArticles.add(article);
        } catch (e) {
          // Error handling using Logger
        }
      }
    }

    setState(() {
      _articles.addAll(cachedArticles);
    });

    if (cachedArticles.length < articlesFetchedAtATime) {
      _fetchArticles();
    }
  }

  void _fetchArticles() {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final aggregationService = AggregationService(
      FetchNewsArticlesService(ApiConfig.newsApiKey),
      ContentSummarizationService(ApiConfig.summaryApiKey),
      ImageOptimizationService(),
    );

    aggregationService
        .aggregateArticlesStream(_currentPage, articlesFetchedAtATime)
        .listen((article) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            if (_articles.length >= _maxArticlesCount) {
              _cacheManager.removeFile(_articles[0].imageFilePath.path);
              _articles.removeAt(0);
            }
            _articles.add(article);
            _isInitialLoad = false;
          });
        });
      }
    }, onDone: () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _isLoading = false;
            if (_articles.length < articlesFetchedAtATime) {
              _currentPage++;
              _fetchArticles();
            }
          });
        });
      }
    });
  }

  Future<void> _refreshArticles() async {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      _isInitialLoad = true;
    });
    _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshArticles,
              child: ListView.builder(
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  if (index >= _articles.length - articlesFetchedAtATime &&
                      !_isLoading) {
                    _fetchArticles();
                  }
                  return NewsCard(article: _articles[index]);
                },
              ),
            ),
    );
  }
}
