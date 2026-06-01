import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';
import 'package:radioquiz/features/quiz/screens/home_screen.dart';

/// Builds a [MaterialApp] wrapping [HomeScreen] with routes needed for
/// navigation testing. Also initializes the [UIConstants] singleton.
Widget buildTestApp() {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        UIConstants().init(context);
        return const HomeScreen();
      },
    ),
    routes: {
      '/quiz': (context) => const Scaffold(
            body: Center(child: Text('Quiz Page')),
          ),
    },
  );
}

void main() {
  testWidgets('displays the title "Radio Quiz" in the app bar', (tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Radio Quiz'), findsOneWidget);
  });

  testWidgets('displays all three level buttons: Level 1, Level 2, Level 3',
      (tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Level 3'), findsOneWidget);
  });

  testWidgets('tapping Level 1 navigates to the quiz screen', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Level 1'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Page'), findsOneWidget);
  });

  testWidgets('tapping Level 2 navigates to the quiz screen', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Level 2'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Page'), findsOneWidget);
  });

  testWidgets('tapping Level 3 navigates to the quiz screen', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Level 3'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Page'), findsOneWidget);
  });
}
