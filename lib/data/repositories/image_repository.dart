import 'package:flutter/services.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:path/path.dart';

class ImageRepository {
  static final String basePath = AppConstants.imagePath;

  /// cache for image paths to avoid scanning the asset manifest on every call
  static final Map<String, Map<String, String>> _cache = {};

  Future<Map<String, String>> fetchImages(String level) async {
    // chace hit
    if (_cache.containsKey(level)) {
      return _cache[level]!;
    }

    final String levelPath = join(basePath, level);
    final Map<String, String> result = await _loadImagePaths(levelPath);

    // cache the result for future calls
    _cache[level] = result;
    return result;
  }

  /// read image paths from assets
  Future<Map<String, String>> _loadImagePaths(String folderPath) async {
    try {
      final AssetManifest manifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> allAssets = manifest.listAssets();

      final Map<String, String> imageMap = {};

      for (final String key in allAssets) {
        if (key.startsWith(folderPath)) {
          final String fileName = key.split('/').last;
          imageMap[fileName] = key;
        }
      }

      return imageMap;
    } catch (e) {
      throw Exception("Error loading image paths: $e");
    }
  }
}
