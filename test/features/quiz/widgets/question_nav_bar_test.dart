import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/features/quiz/widgets/question_nav_bar.dart';

void main() {
  group('QuestionNavBar', () {
    testWidgets('displays the correct number of cells', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionNavBar(
              totalQuestions: 5,
              currentIndex: 0,
              answerStates: [null, null, null, null, null],
              onQuestionTap: (_) {},
            ),
          ),
        ),
      );

      for (int i = 1; i <= 5; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('calls onQuestionTap with the correct index when tapped',
        (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionNavBar(
              totalQuestions: 3,
              currentIndex: 0,
              answerStates: [null, null, null],
              onQuestionTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(tappedIndex, 2); // 0-based index
    });

    testWidgets('answered cells show green, current cell shows blue',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionNavBar(
              totalQuestions: 3,
              currentIndex: 1,
              answerStates: [0, null, null], // Question 1 answered
              onQuestionTap: (_) {},
            ),
          ),
        ),
      );
    });
  });
}
