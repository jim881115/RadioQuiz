import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/data/repositories/question_repository.dart';
import 'package:radioquiz/data/repositories/image_repository.dart';

final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizState>((ref) {
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

class QuizState {
  final List<Question> questions;
  final Map<String, String> imagePaths;
  final int currentIndex;
  final List<int?> selectedAnswers;
  final int remainingTime;
  final bool isCompleted;
  final bool isLoading;
  final String? error;

  const QuizState({
    this.questions = const [],
    this.imagePaths = const {},
    this.currentIndex = 0,
    this.selectedAnswers = const [],
    this.remainingTime = AppConstants.quizDuration,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
  });

  QuizState copyWith({
    List<Question>? questions,
    Map<String, String>? imagePaths,
    int? currentIndex,
    List<int?>? selectedAnswers,
    int? remainingTime,
    bool? isCompleted,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      imagePaths: imagePaths ?? this.imagePaths,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingTime: remainingTime ?? this.remainingTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  bool get hasUnanswered => selectedAnswers.any((a) => a == null);

  int get totalQuestions => questions.length;

  Question get currentQuestion => questions[currentIndex];
}

class QuizController extends StateNotifier<QuizState> {
  final QuestionRepository questionRepository;
  final ImageRepository imageRepository;
  Timer? _timer;

  QuizController(this.questionRepository, this.imageRepository)
      : super(const QuizState());

  /// load specified level questions/pictures and start timer
  Future<void> load(String level) async {
    state = state.copyWith(isLoading: true, error: null, clearError: true);

    try {
      final questions = await questionRepository.fetchQuestions(level);
      final imagePaths = await imageRepository.fetchImages(level);

      state = QuizState(
        questions: questions,
        imagePaths: imagePaths,
        selectedAnswers: List<int?>.filled(questions.length, null),
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingTime > 1) {
        state = state.copyWith(remainingTime: state.remainingTime - 1);
      } else {
        // timeout
        _timer?.cancel();
        state = state.copyWith(remainingTime: 0, isCompleted: true);
      }
    });
  }

  void selectAnswer(int index) {
    if (state.isCompleted) return;
    final updated = [...state.selectedAnswers];
    updated[state.currentIndex] = index;
    state = state.copyWith(selectedAnswers: updated);
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < state.totalQuestions) {
      state = state.copyWith(currentIndex: index);
    }
  }

  void goToNext() => goToQuestion(state.currentIndex + 1);

  void goToPrevious() => goToQuestion(state.currentIndex - 1);

  void submit() {
    _timer?.cancel();
    state = state.copyWith(isCompleted: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
