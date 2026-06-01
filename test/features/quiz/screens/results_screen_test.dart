import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/data/repositories/question_repository.dart';
import 'package:radioquiz/data/repositories/image_repository.dart';
import 'package:radioquiz/features/quiz/screens/results_screen.dart';
import 'package:radioquiz/features/quiz/viewmodels/quiz_viewmodel.dart';

/// A [QuizController] that does nothing on [load], allowing tests to
/// pre-configure the exact [QuizState] without side effects.
class _SilentResultsController extends QuizController {
  _SilentResultsController(super.questionRepository, super.imageRepository);

  @override
  Future<void> load(String level) async {
    // No-op: prevent any background load from interfering.
  }
}

/// Creates a [ProviderScope] wrapping a MaterialApp with [ResultsScreen].
///
/// The app has two routes: `/` (Home) and `/results` (ResultsScreen).
/// When [startAtHome] is true the app begins at `/`, otherwise at `/results`.
ProviderScope buildResultsApp(QuizState state,
    {String level = 'level1', bool startAtHome = false}) {
  final questionRepo = QuestionRepository();
  final imageRepo = ImageRepository();
  final controller = _SilentResultsController(questionRepo, imageRepo);

  // ignore: invalid_use_of_protected_member
  controller.state = state;

  return ProviderScope(
    overrides: [
      quizControllerProvider.overrideWith((ref) => controller),
    ],
    child: MaterialApp(
      initialRoute: startAtHome ? '/' : '/results',
      routes: {
        '/': (context) => const Scaffold(body: Center(child: Text('Home'))),
        '/results': (context) {
          UIConstants().init(context);
          return ResultsScreen(level: level);
        },
      },
    ),
  );
}

/// Creates a sample question with the given [id] and [answerIndex].
Question makeQuestion({int id = 1, int answerIndex = 0}) {
  return Question(
    id: id,
    type: 'Test',
    questionId: id,
    question: 'Test question $id?',
    options: ['A1', 'B2', 'C3', 'D4'],
    answerIndex: answerIndex,
    hasImage: false,
  );
}

void main() {
  testWidgets('shows congratulations when all answers are correct',
      (tester) async {
    final questions = [makeQuestion(id: 1, answerIndex: 0)];
    final state = QuizState(
      questions: questions,
      selectedAnswers: [0], // All correct.
      imagePaths: {},
      remainingTime: 0,
      isCompleted: true,
    );

    await tester.pumpWidget(buildResultsApp(state));

    expect(find.text('恭喜全對！'), findsOneWidget);
    expect(find.text('🎉'), findsOneWidget);
  });

  testWidgets('shows score summary when there are incorrect answers',
      (tester) async {
    final questions = [
      makeQuestion(id: 1, answerIndex: 0),
      makeQuestion(id: 2, answerIndex: 1),
    ];
    final state = QuizState(
      questions: questions,
      selectedAnswers: [0, 0], // Second answer is wrong.
      imagePaths: {},
      remainingTime: 0,
      isCompleted: true,
    );

    await tester.pumpWidget(buildResultsApp(state));

    // The incorrect question should be displayed as the first review item.
    expect(find.text('Test question 2?'), findsOneWidget);
    // The correct question should not appear in the review.
    expect(find.text('Test question 1?'), findsNothing);
  });

  testWidgets('shows "回主頁" button when all answers are correct',
      (tester) async {
    final questions = [makeQuestion(id: 1, answerIndex: 0)];
    final state = QuizState(
      questions: questions,
      selectedAnswers: [0],
      imagePaths: {},
      remainingTime: 0,
      isCompleted: true,
    );

    await tester.pumpWidget(buildResultsApp(state));

    expect(find.text('回主頁'), findsOneWidget);
  });

  testWidgets('shows "回主頁" button when there are incorrect answers',
      (tester) async {
    final questions = [
      makeQuestion(id: 1, answerIndex: 0),
      makeQuestion(id: 2, answerIndex: 1),
    ];
    final state = QuizState(
      questions: questions,
      selectedAnswers: [0, 0],
      imagePaths: {},
      remainingTime: 0,
      isCompleted: true,
    );

    await tester.pumpWidget(buildResultsApp(state));

    expect(find.text('回主頁'), findsOneWidget);
  });

  testWidgets('tapping "回主頁" does not throw', (tester) async {
    final questions = [makeQuestion(id: 1, answerIndex: 0)];
    final state = QuizState(
      questions: questions,
      selectedAnswers: [0],
      imagePaths: {},
      remainingTime: 0,
      isCompleted: true,
    );

    await tester.pumpWidget(buildResultsApp(state));

    // Verify tapping the button completes without throwing.
    await tester.tap(find.text('回主頁'));
    await tester.pumpAndSettle();
  });
}
