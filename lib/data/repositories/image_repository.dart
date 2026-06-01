import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:path/path.dart';

/// Repository for loading image file paths from the application asset bundle.
///
/// Results are cached in memory so subsequent calls for the same level
/// skip re-scanning the asset manifest.
class ImageRepository {
  static final String basePath = AppConstants.imagePath;
  static final Map<String, Map<String, String>> _cache = {};
  final AssetBundle? _bundle;

  /// Creates a repository that uses [rootBundle] for asset lookups.
  ImageRepository() : _bundle = null;

  /// Creates a repository with a custom [AssetBundle] (for testing only).
  @visibleForTesting
  ImageRepository.test(this._bundle);

  /// Clears the in-memory cache (for testing only).
  @visibleForTesting
  static void resetCache() => _cache.clear();

  /// Seeds the cache with test data (for testing only).
  @visibleForTesting
  static void seedCache(String level, Map<String, String> data) =>
      _cache[level] = data;

  /// Returns a map of filename → full asset path for all images in [level].
  ///
  /// The result is cached; subsequent calls return the cached map directly.
  Future<Map<String, String>> fetchImages(String level) async {
    // cache hit
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
      final AssetBundle bundle = _bundle ?? rootBundle;
      final AssetManifest manifest =
          await AssetManifest.loadFromAssetBundle(bundle);
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
