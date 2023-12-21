import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

class ImageOptimizationService {
  Future<File> optimizeImage(String imageUrl) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        Uint8List imageData = response.bodyBytes;
        var dir = await getTemporaryDirectory();
        var uuid = const Uuid();
        String fileName = uuid.v4();

        var compressedImage = await FlutterImageCompress.compressWithList(
          imageData,
          quality: 80,
          minWidth: 500,
          minHeight: 500,
          format: CompressFormat.jpeg,
        );

        String filePath = '${dir.path}/$fileName.jpg';
        File file = File(filePath);
        await file.writeAsBytes(compressedImage);
        return file;
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      throw Exception('Error optimizing image: $e');
    }
  }
}
