import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:radioquiz/data/repositories/question_repository.dart';
import 'package:radioquiz/core/constants/app_constants.dart';

void main() {
  late Database db;
  late QuestionRepository repository;

  /// Creates all three level tables and inserts sample data matching the
  /// distribution rules defined in [AppConstants.questionDistribution].
  Future<Database> createTestDatabase() async {
    final dbb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    // Create all three level tables with the same schema.
    for (final level in ['level1', 'level2', 'level3']) {
      await dbb.execute('''
        CREATE TABLE $level (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          question_id INTEGER NOT NULL,
          question TEXT NOT NULL,
          option1 TEXT NOT NULL,
          option2 TEXT NOT NULL,
          option3 TEXT NOT NULL,
          option4 TEXT NOT NULL,
          answer INTEGER NOT NULL,
          has_image INTEGER NOT NULL DEFAULT 0,
          image TEXT
        )
      ''');
    }

    // Insert sample data for all three levels.
    int qId = 0;
    for (final levelEntry in AppConstants.questionDistribution.entries) {
      final levelName = levelEntry.key;
      final categories = levelEntry.value;

      for (final catEntry in categories.entries) {
        for (int i = 0; i < catEntry.value; i++) {
          qId++;
          await dbb.insert(levelName, {
            'category': catEntry.key,
            'question_id': qId,
            'question': 'Sample question $qId',
            'option1': 'A',
            'option2': 'B',
            'option3': 'C',
            'option4': 'D',
            'answer': i % 4,
            'has_image': 0,
          });
        }
      }
    }

    return dbb;
  }

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    db = await createTestDatabase();
    repository = QuestionRepository.test(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('QuestionRepository', () {
    for (final level in ['level1', 'level2', 'level3']) {
      final expectedTotal = AppConstants.questionDistribution[level]!.values
          .fold(0, (a, b) => a + b);

      test('$level returns $expectedTotal questions', () async {
        final questions = await repository.fetchQuestions(level);

        expect(questions, isNotEmpty);
        expect(questions.length, expectedTotal);
        expect(questions.every((q) => q.type.isNotEmpty), isTrue);
      });

      test('$level questions each have exactly 4 options', () async {
        final questions = await repository.fetchQuestions(level);

        for (final q in questions) {
          expect(q.options.length, 4);
        }
      });
    }

    test('fetchQuestions throws for an invalid level', () async {
      expect(
        () => repository.fetchQuestions('invalid_level'),
        throwsException,
      );
    });

    test('fetchQuestions throws when database is not initialized', () async {
      final uninitializedRepo = QuestionRepository();

      expect(
        () => uninitializedRepo.fetchQuestions('level1'),
        throwsException,
      );
    });
  });
}
