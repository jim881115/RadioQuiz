import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/shared/widgets/error_view.dart';

void main() {
  testWidgets('displays the error message text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
          home: Scaffold(body: ErrorView(message: 'Something went wrong'))),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('shows retry button when onRetry is provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorView(message: 'Error', onRetry: _doNothing),
        ),
      ),
    );

    expect(find.text('重試'), findsOneWidget);
  });

  testWidgets('does not show retry button when onRetry is null',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ErrorView(message: 'Error'))),
    );

    expect(find.text('重試'), findsNothing);
  });

  testWidgets('tapping retry button calls the onRetry callback',
      (tester) async {
    bool retryCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Error',
            onRetry: () => retryCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('重試'));
    await tester.pump();

    expect(retryCalled, isTrue);
  });
}

/// A no-op callback used as a placeholder for [ErrorView.onRetry].
void _doNothing() {}
