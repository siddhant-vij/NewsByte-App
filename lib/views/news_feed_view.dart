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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await ApiConfig.loadConfig();
    await _loadArticlesFromCache();
  }

  Future<void> _loadArticlesFromCache() async {
    var cachedArticles = await _getCachedArticles();
    if (cachedArticles.isNotEmpty) {
      _addArticlesToFeed(cachedArticles);
    } else {
      _fetchArticles();
    }
  }

  Future<List<NewsArticle>> _getCachedArticles() async {
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
        String content = await fileInfo.file.readAsString();
        cachedArticles.add(NewsArticle.fromJson(json.decode(content)));
      }
    }
    return cachedArticles;
  }

  void _fetchArticles() {
    if (_isLoading) return;
    _setLoadingState(true);

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
          _handleNewArticle(article);
        });
      }
    }, onDone: () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleStreamDone();
        });
      }
    });
  }

  void _handleNewArticle(NewsArticle article) {
    setState(() {
      if (_articles.length >= _maxArticlesCount) {
        _removeOldestArticles();
      }
      _articles.add(article);
      _isInitialLoad = false;
    });
  }

  void _handleStreamDone() {
    _setLoadingState(false);
    if (_articles.length < articlesFetchedAtATime) {
      _currentPage++;
      _fetchArticles();
    }
  }

  void _removeOldestArticles() {
    for (int i = 0; i < articlesToBeRemoved; i++) {
      _cacheManager.removeFile(_articles[i].imageFilePath.path);
    }
    _articles.removeRange(0, articlesToBeRemoved);
  }

  void _addArticlesToFeed(List<NewsArticle> articles) {
    setState(() {
      _articles.addAll(articles);
    });
  }

  void _setLoadingState(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> _refreshArticles() async {
    _setLoadingState(true);
    _articles.clear();
    _currentPage = 1;
    _isInitialLoad = true;
    _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _isInitialLoad
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refreshArticles,
            child: _buildListView(),
          );
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        if (_shouldFetchMoreArticles(index)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fetchArticles();
          });
        }
        return NewsCard(article: _articles[index]);
      },
    );
  }

  bool _shouldFetchMoreArticles(int index) {
    return index >= _articles.length - articlesFetchedAtATime && !_isLoading;
  }
}
