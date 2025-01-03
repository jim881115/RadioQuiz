import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/repositories/question_repository.dart';
import 'features/quiz/screens/home_screen.dart';
import 'features/quiz/screens/quiz_screen.dart';
import 'features/quiz/screens/results_screen.dart';
import 'features/quiz/viewmodels/quiz_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化資料庫
  final questionRepository = QuestionRepository();
  await questionRepository.initDatabase();

  runApp(ProviderScope(
    overrides: [
      questionRepositoryProvider.overrideWithValue(questionRepository),
    ],
    child: const QuizApp(),
  ));
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radio Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/quiz': (context) {
          final level = ModalRoute.of(context)!.settings.arguments as String;
          return QuizScreen(level: level);
        },
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}