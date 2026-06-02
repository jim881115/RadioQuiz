import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/data/repositories/question_repository.dart';
import 'package:radioquiz/data/repositories/image_repository.dart';
import 'package:radioquiz/features/quiz/screens/results_screen.dart';
import 'package:radioquiz/features/quiz/viewmodels/quiz_viewmodel.dart';
import 'package:radioquiz/features/quiz/widgets/question_nav_bar.dart';

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
  testWidgets('shows score 1 / 1 when all answers are correct', (tester) async {
    final questions = [makeQuestion(id: 1, answerIndex: 0)];
    final state = QuizState(
      questions: questions,
      selectedAnswers: [0], // All correct.
      imagePaths: {},
      remainingTime: 0,
      isCompleted: true,
    );

    await tester.pumpWidget(buildResultsApp(state));

    // Score row shows all correct.
    expect(find.textContaining('1 / 1'), findsOneWidget);
    // All questions are shown for review (not a separate congrats page).
    expect(find.text('Test question 1?'), findsOneWidget);
  });

  testWidgets('shows all questions in review regardless of correctness',
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

    // Starts at question 1 (currentIndex=0), which is correct.
    expect(find.text('Test question 1?'), findsOneWidget);
    // Score row shows 1 / 2.
    expect(find.textContaining('1 / 2'), findsOneWidget);
  });

  testWidgets('navigates to incorrect question via nav bar', (tester) async {
    final questions = [
      makeQuestion(id: 1, answerIndex: 0),
      makeQuestion(id: 2, answerIndex: 1),
    ];
    final state = QuizState(
      questions: questions,
      selectedAnswers: [0, 0], // Second is wrong.
      imagePaths: {},
      remainingTime: 0,
      isCompleted: true,
    );

    await tester.pumpWidget(buildResultsApp(state));

    // Tap question number "2" in the nav bar.
    final navBar = find.byType(QuestionNavBar);
    await tester.tap(find.descendant(of: navBar, matching: find.text('2')));
    await tester.pump();

    // Now shows question 2 (the wrong one).
    expect(find.text('Test question 2?'), findsOneWidget);
  });

  testWidgets('shows "回主頁" button', (tester) async {
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
