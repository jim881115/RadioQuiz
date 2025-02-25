import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/data/repositories/question_repository.dart';
import 'package:radioquiz/data/repositories/image_repository.dart';

final quizControllerProvider = StateNotifierProvider<QuizController, QuizState>((ref) {
  final questionRepository = ref.read(questionRepositoryProvider);
  final imageRepository = ref.read(imageRepositoryProvider);
  return QuizController(questionRepository, imageRepository);
});

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  return ImageRepository();
});

/// 定義 Quiz 狀態（包含題目 & 圖片）
class QuizState {
  final List<Question> questions;
  final Map<String, String> imagePaths;

  QuizState({required this.questions, required this.imagePaths});
}

class QuizController extends StateNotifier<QuizState> {
  final QuestionRepository questionRepository;
  final ImageRepository imageRepository;

  QuizController(this.questionRepository, this.imageRepository) 
      : super(QuizState(questions: [], imagePaths: {}));

  Future<void> load(String level) async {
    final questions = await questionRepository.fetchQuestions(level);
    final imagePaths = await imageRepository.fetchImages(level);

    state = QuizState(questions: questions, imagePaths: imagePaths);
  }
}
