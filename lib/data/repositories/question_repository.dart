import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:radioquiz/data/models/question.dart';

class QuestionRepository {
  Database? _db;

  Future<void> initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, AppConstants.databaseName);
    final File dbFile = File(path);

    // check with database not exist
    if (!await dbFile.exists()) {
      try {
        final ByteData data = await rootBundle.load(
          join(AppConstants.databasePath, AppConstants.databaseName),
        );
        final List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        await dbFile.writeAsBytes(bytes);
      } catch (e) {
        throw Exception("Error copying database: $e");
      }
    }

    _db = await openDatabase(path);
  }

  Future<List<Question>> fetchQuestions(String level) async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }

    // get level question distribution rules
    final questionRules = AppConstants.questionDistribution[level];

    if (questionRules == null) {
      throw Exception("Invalid level: $level");
    }

    List<Question> selectedQuestions = [];

    // get questions based on distribution rules
    for (var entry in questionRules.entries) {
      String category = entry.key;
      int count = entry.value;

      final List<Map<String, dynamic>> maps = await _db!.rawQuery(
          "SELECT * FROM $level WHERE category = ? ORDER BY RANDOM() LIMIT ?",
          // "SELECT * FROM $level WHERE category = ? AND has_image = 1 ORDER BY RANDOM() LIMIT ?", // 只取有圖片的題目
          [category, count]);

      selectedQuestions.addAll(maps.map((map) => Question.fromMap(map)));
    }

    return selectedQuestions;
  }
}
