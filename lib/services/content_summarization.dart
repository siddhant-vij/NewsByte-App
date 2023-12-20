import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:newsbyte/utils/constants.dart';

class ContentSummarizationService {
  final String summaryApiKey;

  ContentSummarizationService(this.summaryApiKey);

  Future<String> summarizeContent(String text, int length) async {
    const String apiUrl = summaryEndpoint;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $summaryApiKey',
    };
    final body = {
      'model': 'gpt-4',
      'messages': [
        {
          'role': 'system',
          'content':
              'Your task is to summarize the content within $length words. Ignore using starting text like "This passage highlights" etc. Directly start off with the text summary.'
        },
        {
          'role': 'user',
          'content': text,
        },
      ],
      'temperature': 0.7,
      'max_tokens': 100,
      'top_p': 1,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('Failed to summarize content');
    }
  }
}
