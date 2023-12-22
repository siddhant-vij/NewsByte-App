import 'package:flutter/material.dart';

import 'package:newsbyte/views/news_feed_view.dart';

void main() {
  runApp(const NewsByteApp());
}

class NewsByteApp extends StatelessWidget {
  const NewsByteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsByte',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const NewsFeedView(),
    );
  }
}
