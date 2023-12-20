import 'package:flutter/services.dart';

import 'package:newsbyte/utils/constants.dart';

class ApiConfig {
  static String? _newsApiKey;
  static String? _summaryApiKey;

  static Future<void> loadConfig() async {
    var configFile = await rootBundle.loadString(configFilePath);

    List<String> lines = configFile.split('\n');
    for (var line in lines) {
      if (line.startsWith('NEWS_API_KEY=')) {
        _newsApiKey = line.split('=')[1].trim();
      } else if (line.startsWith('SUMMARY_API_KEY=')) {
        _summaryApiKey = line.split('=')[1].trim();
      }
    }
  }

  static String get newsApiKey {
    return _newsApiKey ?? '';
  }

  static String get summaryApiKey {
    return _summaryApiKey ?? '';
  }
}
