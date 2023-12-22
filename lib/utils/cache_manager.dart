import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:newsbyte/utils/constants.dart';

class CustomCacheManager {
  static const key = 'customCacheKey';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: articlesFetchedAtATime,
    ),
  );
}
