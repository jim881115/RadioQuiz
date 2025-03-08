import 'package:flutter/material.dart';

class AppConstants {
  static const String databasePath = 'assets/database';
  static const String databaseName = 'questions.db';
  static const String imagePath = 'assets/image';
  static const String iconPath = 'assets/image/icon/radio_icon.svg';
  static const int quizDuration = 40 * 60;

  static const Map<String, Map<String, int>> questionDistribution = {
    'level3': {
      '無線電規章與相關法規': 13,
      '無線電通訊方法': 13,
      '無線電系統原理': 6,
      '無線電相關安全防護': 1,
      '電磁相容性技術': 1,
      '射頻干擾的預防與排除': 1,
    },
    'level2': {
      '無線電規章與相關法規': 12,
      '無線電通訊方法': 12,
      '無線電系統原理': 10,
      '無線電相關安全防護': 2,
      '電磁相容性技術': 2,
      '射頻干擾的預防與排除': 2,
    },
    'level1': {
      '無線電規章與相關法規': 13,
      '無線電通訊方法': 15,
      '無線電系統原理': 15,
      '無線電相關安全防護': 3,
      '電磁相容性技術': 2,
      '射頻干擾的預防與排除': 2,
    },
  };

  static const Map<String, int> quizPassingScore = {
    'level3': 25,
    'level2': 32,
    'level1': 40,
  };
}
