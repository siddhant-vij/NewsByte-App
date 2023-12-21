import 'package:newsbyte/models/news_article.dart';
import 'package:newsbyte/services/content_summarization.dart';
import 'package:newsbyte/services/fetch_news_articles.dart';
import 'package:newsbyte/services/image_optimization.dart';

class AggregationService {
  final FetchNewsArticlesService fetchNewsArticlesService;
  final ContentSummarizationService contentSummarizationService;
  final ImageOptimizationService imageOptimizationService;

  AggregationService(this.fetchNewsArticlesService,
      this.contentSummarizationService, this.imageOptimizationService);

  Future<List<NewsArticle>> aggregateArticlesPage(
      int page, int pageSize) async {
    List<Map<String, dynamic>> articlesData = await fetchNewsArticlesService
        .fetchNewsArticles(page: page, pageSize: pageSize);
    List<Future<NewsArticle>> articleFutures =
        articlesData.map(_processArticle).toList();

    return await Future.wait(articleFutures);
  }

  Future<NewsArticle> _processArticle(Map<String, dynamic> articleData) async {
    String title = articleData['title'];
    String combinedDescriptionAndContent =
        articleData['description'] + " " + articleData['content'];

    String summarizedTitle =
        await contentSummarizationService.summarizeContent(title, 8);
    String summarizedDescription = await contentSummarizationService
        .summarizeContent(combinedDescriptionAndContent, 80);

    var optimizedImagePath =
        await imageOptimizationService.optimizeImage(articleData['urlToImage']);

    return NewsArticle(
      sourceName: articleData['source']['name'] as String,
      url: articleData['url'] as String,
      title: summarizedTitle,
      description: summarizedDescription,
      publishedAt: DateTime.parse(articleData['publishedAt']),
      imageFilePath: optimizedImagePath,
    );
  }
}
