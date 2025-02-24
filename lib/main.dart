import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/repositories/question_repository.dart';
import 'features/quiz/screens/home_screen.dart';
import 'features/quiz/screens/quiz_screen.dart';
import 'features/quiz/screens/results_screen.dart';
import 'features/quiz/viewmodels/quiz_viewmodel.dart';
import 'data/models/question.dart';

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
        '/results': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String level = args['level'] as String;
          final List<Question> questions = args['questions'] as List<Question>;
          final List<int?> selectedAnswers = args['selectedAnswers'] as List<int?>;
          return ResultsScreen(
            level: level,
            questions: questions,
            selectedAnswers: selectedAnswers,
          );
        },
      },
    );
  }
}