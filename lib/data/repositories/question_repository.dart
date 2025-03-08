import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:radioquiz/data/models/question.dart';

class QuestionRepository {
  Database? _db;

  Future<void> initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, AppConstants.databaseName);

    try {
      ByteData data = await rootBundle
          .load(join(AppConstants.databasePath, AppConstants.databaseName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes);
    } catch (e) {
      throw Exception("Error copying database: $e");
    }

    _db = await openDatabase(path);
  }

  Future<List<Question>> fetchQuestions(String level) async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    // 取得該等級的出題規則
    final questionRules = AppConstants.questionDistribution[level];

    if (questionRules == null) {
      throw Exception("Invalid level: $level");
    }

    List<Question> selectedQuestions = [];

    // 依照類別隨機抽取題目
    for (var entry in questionRules.entries) {
      String category = entry.key; // 類型名稱
      int count = entry.value; // 要抽取的數量

      final List<Map<String, dynamic>> maps = await _db!.rawQuery(
          "SELECT * FROM $level WHERE category = ? ORDER BY RANDOM() LIMIT ?",
          // "SELECT * FROM $level WHERE category = ? AND has_image = 1 ORDER BY RANDOM() LIMIT ?", // 只取有圖片的題目
          [category, count]);

      selectedQuestions.addAll(maps.map((map) => Question.fromMap(map)));
    }

    return selectedQuestions;
  }
}
