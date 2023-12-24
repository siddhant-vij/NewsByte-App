import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import 'package:newsbyte/utils/constants.dart';

class ContentSummarizationService {
  final String summaryApiKey;

  ContentSummarizationService(this.summaryApiKey);

  Future<String> summarizeContent(String text, int length) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_summarizeContentIsolate, receivePort.sendPort);

    final SendPort isolateSendPort = await receivePort.first as SendPort;

    ReceivePort responsePort = ReceivePort();
    isolateSendPort.send({
      'text': text,
      'length': length,
      'apiKey': summaryApiKey,
      'replyPort': responsePort.sendPort
    });

    final response = await responsePort.first as Map<String, dynamic>;
    if (response['status'] == 'success') {
      return response['data'];
    } else {
      throw Exception(response['error']);
    }
  }

  static void _summarizeContentIsolate(SendPort mainIsolateSendPort) {
    ReceivePort port = ReceivePort();
    mainIsolateSendPort.send(port.sendPort);

    port.listen((message) {
      var text = message['text'] as String;
      var length = message['length'] as int;
      var apiKey = message['apiKey'] as String;
      var replyPort = message['replyPort'] as SendPort;

      _makeApiCall(text, length, apiKey).then((result) {
        replyPort.send({'status': 'success', 'data': result});
      }).catchError((e) {
        replyPort.send({'status': 'error', 'error': e.toString()});
      });
    });
  }

  static Future<String> _makeApiCall(
      String text, int length, String apiKey) async {
    const String apiUrl = summaryEndpoint;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
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
      'max_tokens': 200,
      'top_p': 1,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('Failed to summarize content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to summarize content: $e');
    }
  }
}
