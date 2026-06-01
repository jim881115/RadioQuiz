import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:radioquiz/data/repositories/question_repository.dart';
import 'package:radioquiz/data/repositories/image_repository.dart';
import 'package:radioquiz/features/quiz/viewmodels/quiz_viewmodel.dart';

void main() {
  late Database db;
  late QuestionRepository questionRepo;
  late QuizController controller;

  /// Creates an in-memory database with a level1 table and sample questions
  /// matching the distribution defined in [AppConstants].
  Future<Database> createTestDatabase() async {
    final dbb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

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

    // Insert sample questions for all levels.
    int qId = 0;
    for (final levelEntry in AppConstants.questionDistribution.entries) {
      final levelName = levelEntry.key;
      for (final catEntry in levelEntry.value.entries) {
        for (int i = 0; i < catEntry.value; i++) {
          qId++;
          await dbb.insert(levelName, {
            'category': catEntry.key,
            'question_id': qId,
            'question': 'Sample question $qId',
            'option1': 'Option A',
            'option2': 'Option B',
            'option3': 'Option C',
            'option4': 'Option D',
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
    questionRepo = QuestionRepository.test(db);

    // Seed the image cache so fetchImages returns data immediately.
    ImageRepository.resetCache();
    ImageRepository.seedCache(
        'level1', {'q1.png': 'assets/image/level1/q1.png'});

    final imageRepo = ImageRepository();
    controller = QuizController(questionRepo, imageRepo);
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
    ImageRepository.resetCache();
  });

  group('QuizState initial state', () {
    test('starts with empty questions, not loading, no error', () {
      expect(controller.state.questions, isEmpty);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.error, isNull);
      expect(controller.state.isCompleted, isFalse);
      expect(controller.state.currentIndex, 0);
    });

    test('starts with zero-length selectedAnswers', () {
      expect(controller.state.selectedAnswers, isEmpty);
      expect(controller.state.hasUnanswered, isFalse);
    });

    test('initial remainingTime equals quizDuration', () {
      expect(controller.state.remainingTime, AppConstants.quizDuration);
    });
  });

  group('QuizController.load', () {
    test('loads questions and sets isLoading to false on success', () async {
      await controller.load('level1');

      expect(controller.state.questions, isNotEmpty);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.error, isNull);
    });

    test('creates selectedAnswers matching question count', () async {
      await controller.load('level1');

      expect(
        controller.state.selectedAnswers.length,
        controller.state.totalQuestions,
      );
      expect(controller.state.selectedAnswers.every((a) => a == null), isTrue);
    });

    test('sets remainingTime to quizDuration after loading', () async {
      await controller.load('level1');

      // Timer has started; value should be at most the initial duration.
      expect(controller.state.remainingTime,
          lessThanOrEqualTo(AppConstants.quizDuration));
      expect(controller.state.remainingTime, greaterThan(0));
    });

    test('sets error state when loading fails', () async {
      // Attempt to load a level that doesn't exist in the database.
      // The database only has level1, level2, level3.
      // Use a level that has distribution rules but no table data won't fail,
      // because we created all three tables above. Instead, trigger a failure
      // by passing a level not in AppConstants.questionDistribution.
      await controller.load('nonexistent');

      expect(controller.state.error, isNotNull);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.questions, isEmpty);
    });
  });

  group('QuizController navigation', () {
    setUp(() async {
      await controller.load('level1');
    });

    test('goToNext increments currentIndex', () {
      final before = controller.state.currentIndex;
      controller.goToNext();
      expect(controller.state.currentIndex, before + 1);
    });

    test('goToPrevious decrements currentIndex', () {
      // Move to question 2 first, then back.
      controller.goToNext();
      final before = controller.state.currentIndex;
      controller.goToPrevious();
      expect(controller.state.currentIndex, before - 1);
    });

    test('goToNext does not go past the last question', () {
      // Jump to the last question.
      controller.goToQuestion(controller.state.totalQuestions - 1);
      controller.goToNext();
      // Should stay at the last question.
      expect(
          controller.state.currentIndex, controller.state.totalQuestions - 1);
    });

    test('goToPrevious does not go before the first question', () {
      controller.goToPrevious();
      expect(controller.state.currentIndex, 0);
    });

    test('goToQuestion jumps to a specific index', () {
      controller.goToQuestion(3);
      expect(controller.state.currentIndex, 3);
    });
  });

  group('QuizController answer selection', () {
    setUp(() async {
      await controller.load('level1');
    });

    test('selectAnswer records the chosen answer', () {
      controller.selectAnswer(2);
      expect(
          controller.state.selectedAnswers[controller.state.currentIndex], 2);
    });

    test('selectAnswer can be overwritten', () {
      controller.selectAnswer(0);
      controller.selectAnswer(3);
      expect(
          controller.state.selectedAnswers[controller.state.currentIndex], 3);
    });

    test('hasUnanswered is true when some questions are unanswered', () {
      // After load, all answers are null.
      expect(controller.state.hasUnanswered, isTrue);
    });

    test('hasUnanswered is false when all questions are answered', () {
      // Answer all questions.
      for (int i = 0; i < controller.state.totalQuestions; i++) {
        controller.selectAnswer(0);
        if (i < controller.state.totalQuestions - 1) {
          controller.goToNext();
        }
      }
      expect(controller.state.hasUnanswered, isFalse);
    });
  });

  group('QuizController submit', () {
    setUp(() async {
      await controller.load('level1');
    });

    test('submit sets isCompleted to true', () {
      controller.submit();
      expect(controller.state.isCompleted, isTrue);
    });

    test('selectAnswer is ignored after submit', () {
      controller.submit();
      controller.selectAnswer(1);
      expect(controller.state.selectedAnswers[controller.state.currentIndex],
          isNull);
    });

    test('submit can be called multiple times without error', () {
      controller.submit();
      controller.submit();
      expect(controller.state.isCompleted, isTrue);
    });
  });
}
