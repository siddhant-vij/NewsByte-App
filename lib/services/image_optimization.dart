import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uuid/uuid.dart';

import 'package:newsbyte/utils/constants.dart';

class ImageOptimizationService {
  final BaseCacheManager _cacheManager = DefaultCacheManager();

  Future<File> optimizeImage(String imageUrl) async {
    String cacheKey = _generateCacheKey(imageUrl);
    FileInfo? cachedFile = await _getFromCache(cacheKey);

    if (cachedFile != null) {
      return cachedFile.file;
    }

    try {
      return await _processAndCacheImage(imageUrl, cacheKey);
    } catch (e) {
      throw Exception('Error in Image Optimization: $e');
    }
  }

  Future<FileInfo?> _getFromCache(String cacheKey) async {
    try {
      return await _cacheManager.getFileFromCache(cacheKey);
    } catch (e) {
      // Consider using a logging framework for better error handling
      return null;
    }
  }

  Future<File> _processAndCacheImage(String imageUrl, String cacheKey) async {
    var response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image: ${response.statusCode}');
    }

    Uint8List imageData = response.bodyBytes;
    var image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    image = _resizeAndCrop(
        image, compressedImageMinWidth, compressedImageMinHeight);
    CompressFormat format = _getOptimalCompressFormat();
    Uint8List encodedImage =
        img.encodeJpg(image, quality: compressedImageQuality);
    var compressedImage = await FlutterImageCompress.compressWithList(
      encodedImage,
      quality: compressedImageQuality,
      minWidth: compressedImageMinWidth,
      minHeight: compressedImageMinHeight,
      format: format,
    );

    String filePath =
        '${(await getTemporaryDirectory()).path}/${const Uuid().v4()}.${format.name}';
    File file = File(filePath);
    await file.writeAsBytes(compressedImage);
    await _cacheManager.putFile(
      cacheKey,
      Uint8List.fromList(compressedImage),
      fileExtension: format.name,
    );

    return file;
  }

  String _generateCacheKey(String imageUrl) {
    return Uri.parse(imageUrl).pathSegments.last;
  }

  img.Image _resizeAndCrop(img.Image image, int targetWidth, int targetHeight) {
    if (image.width < targetWidth) {
      image = img.copyResize(image, width: targetWidth);
    }

    int offsetX = (image.width - targetWidth) ~/ 2;
    int offsetY = (image.height - targetHeight) ~/ 2;
    return img.copyCrop(image,
        x: offsetX, y: offsetY, width: targetWidth, height: targetHeight);
  }

  CompressFormat _getOptimalCompressFormat() {
    if (Platform.isAndroid) {
      return CompressFormat.webp;
    } else if (Platform.isIOS) {
      return CompressFormat.heic;
    } else {
      return CompressFormat.jpeg;
    }
  }
}
