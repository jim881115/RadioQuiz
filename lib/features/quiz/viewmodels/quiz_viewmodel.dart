import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/data/repositories/question_repository.dart';

final quizControllerProvider = StateNotifierProvider<QuizController, List<Question>>((ref) {
  final repository = ref.read(questionRepositoryProvider);
  return QuizController(repository);
});

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

class QuizController extends StateNotifier<List<Question>> {
  final QuestionRepository repository;

  QuizController(this.repository) : super([]);

  Future<void> loadQuestions(String level) async {
    state = await repository.fetchQuestions(level);
  }
}
