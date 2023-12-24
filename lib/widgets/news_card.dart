import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';

import 'package:newsbyte/models/news_article.dart';
import 'package:newsbyte/utils/size_config.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({
    super.key,
    required this.article,
  });

  Future<void> _launchUrl() async {
    Uri url = Uri.parse(article.url);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizedBox(
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight,
      child: Column(
        children: [
          Expanded(
            child: Image.file(
              File(article.imageFilePath.path),
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getHeight(24),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: getHeight(8)),
                Text(
                  article.description,
                  style: TextStyle(
                    fontSize: getHeight(16),
                  ),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: getHeight(8)),
                Row(
                  children: [
                    Text(
                      'short by ',
                      style: TextStyle(
                        fontSize: getHeight(12),
                      ),
                    ),
                    Text(
                      '${article.author} / ',
                      style: TextStyle(
                        fontSize: getHeight(12),
                      ),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd').format(article.publishedAt),
                      style: TextStyle(
                        fontSize: getHeight(12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        // Save for Later functionality will be added later.
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Share functionality will be added later.
                      },
                    ),
                    Row(
                      children: [
                        Text(
                          'More at',
                          style: TextStyle(
                            fontSize: getHeight(16),
                          ),
                        ),
                        TextButton(
                          onPressed: _launchUrl,
                          child: Text(
                            article.sourceName,
                            style: TextStyle(
                              fontSize: getHeight(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
