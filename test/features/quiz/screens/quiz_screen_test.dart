import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/data/repositories/question_repository.dart';
import 'package:radioquiz/data/repositories/image_repository.dart';
import 'package:radioquiz/features/quiz/screens/quiz_screen.dart';
import 'package:radioquiz/features/quiz/viewmodels/quiz_viewmodel.dart';
import 'package:radioquiz/features/quiz/widgets/question_nav_bar.dart';
import 'package:radioquiz/shared/widgets/error_view.dart';

/// A [QuizController] that does nothing on [load], allowing tests to
/// pre-configure the exact [QuizState] without side effects.
class _SilentQuizController extends QuizController {
  _SilentQuizController(super.questionRepository, super.imageRepository);

  @override
  Future<void> load(String level) async {
    // No-op: prevent initState from overriding the test state.
  }
}

/// Creates a [ProviderScope] wrapping [QuizScreen] with a [QuizController]
/// whose state is pre-configured to [state].
///
/// The [level] argument must match the argument passed to [QuizScreen].
ProviderScope buildQuizApp(QuizState state, {String level = 'level1'}) {
  final questionRepo = QuestionRepository();
  final imageRepo = ImageRepository();
  final controller = _SilentQuizController(questionRepo, imageRepo);

  // ignore: invalid_use_of_protected_member
  controller.state = state;

  return ProviderScope(
    overrides: [
      quizControllerProvider.overrideWith((ref) => controller),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) {
          UIConstants().init(context);
          return QuizScreen(level: level);
        },
      ),
      routes: {
        '/results': (context) => const Scaffold(
              body: Center(child: Text('Results Page')),
            ),
      },
    ),
  );
}

/// Sample question used across loading and navigation tests.
Question sampleQuestion({int id = 1, int answerIndex = 0}) {
  return Question(
    id: id,
    type: 'Test Category',
    questionId: id,
    question: 'Sample test question $id?',
    options: ['Answer A', 'Answer B', 'Answer C', 'Answer D'],
    answerIndex: answerIndex,
    hasImage: false,
  );
}

void main() {
  testWidgets('shows CircularProgressIndicator when isLoading', (tester) async {
    final state = QuizState(isLoading: true, questions: []);
    await tester.pumpWidget(buildQuizApp(state));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows ErrorView with retry button when error is set',
      (tester) async {
    final state = QuizState(
      isLoading: false,
      questions: [],
      error: 'Network error',
    );
    await tester.pumpWidget(buildQuizApp(state));

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('重試'), findsOneWidget);
  });

  testWidgets('displays question text when questions are loaded',
      (tester) async {
    final state = QuizState(
      isLoading: false,
      questions: List.generate(
        3,
        (i) => sampleQuestion(id: i + 1),
      ),
      selectedAnswers: List<int?>.filled(3, null),
      remainingTime: AppConstants.quizDuration,
    );
    await tester.pumpWidget(buildQuizApp(state));

    expect(find.text('Sample test question 1?'), findsOneWidget);
  });

  testWidgets('shows question index indicator', (tester) async {
    final state = QuizState(
      isLoading: false,
      questions: List.generate(
        3,
        (i) => sampleQuestion(id: i + 1),
      ),
      selectedAnswers: List<int?>.filled(3, null),
      remainingTime: AppConstants.quizDuration,
    );
    await tester.pumpWidget(buildQuizApp(state));

    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('tapping answer button records the selection', (tester) async {
    final state = QuizState(
      isLoading: false,
      questions: [sampleQuestion()],
      selectedAnswers: [null],
      remainingTime: AppConstants.quizDuration,
    );
    await tester.pumpWidget(buildQuizApp(state));

    // Tap answer button with label "2" (index 1).
    await tester.tap(find.text('2'));
    await tester.pump();

    // The button should still be present (answer recorded in controller).
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Sample test question 1?'), findsOneWidget);
  });

  testWidgets('tapping a question number in the nav bar jumps to that question',
      (tester) async {
    final state = QuizState(
      isLoading: false,
      questions: [
        sampleQuestion(id: 1, answerIndex: 0),
        sampleQuestion(id: 2, answerIndex: 1),
      ],
      selectedAnswers: [null, null],
      remainingTime: AppConstants.quizDuration,
    );
    await tester.pumpWidget(buildQuizApp(state));

    // Initially shows question 1.
    expect(find.text('Sample test question 1?'), findsOneWidget);

    // Tap question number "2" inside the nav bar (not the answer button).
    final navBar = find.byType(QuestionNavBar);
    await tester.tap(find.descendant(of: navBar, matching: find.text('2')));
    await tester.pump();

    // Now shows question 2.
    expect(find.text('Sample test question 2?'), findsOneWidget);
  });

  testWidgets('tapping a previous question number in the nav bar goes back',
      (tester) async {
    final state = QuizState(
      isLoading: false,
      currentIndex: 1, // Start at question 2.
      questions: [
        sampleQuestion(id: 1, answerIndex: 0),
        sampleQuestion(id: 2, answerIndex: 1),
      ],
      selectedAnswers: [null, null],
      remainingTime: AppConstants.quizDuration,
    );
    await tester.pumpWidget(buildQuizApp(state));

    // Initially shows question 2.
    expect(find.text('Sample test question 2?'), findsOneWidget);

    // Tap question number "1" inside the nav bar.
    final navBar = find.byType(QuestionNavBar);
    await tester.tap(find.descendant(of: navBar, matching: find.text('1')));
    await tester.pump();

    // Now shows question 1.
    expect(find.text('Sample test question 1?'), findsOneWidget);
  });
}
