import 'package:flutter/services.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:path/path.dart';

class ImageRepository {
  static String basePath = AppConstants.imagePath;

  /// 取得指定等級的所有圖片路徑
  Future<Map<String, String>> fetchImages(String level) async {
    String levelPath = join(basePath, level);

    // 取得該資料夾下的所有圖片
    return await _loadImagePaths(levelPath);
  }

  /// 讀取 assets 下的圖片路徑
  Future<Map<String, String>> _loadImagePaths(String folderPath) async {
    try {
      final AssetManifest manifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> allAssets = manifest.listAssets();

      Map<String, String> imageMap = {};

      for (var key in allAssets) {
        if (key.startsWith(folderPath)) {
          // 取出檔名 (去掉資料夾路徑)
          String fileName = key.split('/').last;
          imageMap[fileName] = key; // 建立 filename -> 完整路徑 的映射
        }
      }

      return imageMap;
    } catch (e) {
      throw Exception("Error loading image paths: $e");
    }
  }
}
