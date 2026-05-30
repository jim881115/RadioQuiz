import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
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
      final String category = entry.key;
      final int count = entry.value;

      try {
        final List<Map<String, dynamic>> maps = await _db!.rawQuery(
          "SELECT * FROM $level WHERE category = ? ORDER BY RANDOM() LIMIT ?",
          [category, count],
        );

        if (maps.isEmpty) {
          // No questions found for this category, log a warning but continue
          debugPrint(
              "Warning: No questions found for category '$category' in $level");
        }

        selectedQuestions.addAll(maps.map((map) => Question.fromMap(map)));
      } on DatabaseException catch (e) {
        // SQLite error
        throw Exception("資料庫錯誤 ($level/$category): $e");
      }
    }

    if (selectedQuestions.isEmpty) {
      throw Exception("等級 $level 無任何題目，請確認資料庫內容是否正確");
    }

    return selectedQuestions;
  }
}
