import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';
import 'package:radioquiz/core/theme/app_theme.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:radioquiz/features/quiz/viewmodels/quiz_viewmodel.dart';
import 'package:radioquiz/features/quiz/widgets/question_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final String level;

  const ResultsScreen({super.key, required this.level});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  int _currentIndex = 0;
  int _correctCount = 0;
  late double _screenHeight;
  late int _passingScore;
  late bool _isPassed;

  @override
  void initState() {
    super.initState();
    _computeResults();
  }

  void _computeResults() {
    final state = ref.read(quizControllerProvider);
    _correctCount = 0;

    for (int i = 0; i < state.questions.length; i++) {
      if (state.selectedAnswers[i] == state.questions[i].answerIndex) {
        _correctCount++;
      }
    }

    _passingScore =
        AppConstants.quizPassingScore[widget.level] ?? state.questions.length;
    _isPassed = _correctCount >= _passingScore;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizControllerProvider);
    _screenHeight = UIConstants().screenHeight;

    final Question currentQuestion = state.questions[_currentIndex];
    final int? selectedAnswer = state.selectedAnswers[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: UIConstants().screenWidth * 0.2,
        leading: SvgPicture.asset(AppConstants.iconPath),
        title: const Text(
          "Quiz Results",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Score summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                    children: [
                      const TextSpan(text: "答對題數: "),
                      TextSpan(
                        text: "$_correctCount",
                        style: TextStyle(
                          color: _isPassed
                              ? AppTheme.correctGreen
                              : AppTheme.wrongRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: " / ${state.questions.length}"),
                    ],
                  ),
                ),
                Text(
                  "合格標準: $_passingScore 題",
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question index + home button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.infoBlue,
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${state.questions.length}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  child: const Text(
                    "回主頁",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question text
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),

            // Image if present
            if (currentQuestion.hasImage)
              Image.asset(
                state.imagePaths[currentQuestion.image] ?? '',
                fit: BoxFit.contain,
                height: _screenHeight * 0.25,
                width: double.infinity,
              )
            else
              const SizedBox(height: 40),

            // Option list
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final bool isCorrect = index == currentQuestion.answerIndex;
                  final bool isSelected = index == selectedAnswer;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isCorrect
                                ? AppTheme.correctGreenBg
                                : AppTheme.wrongRedBg)
                            : null,
                        border: Border.all(
                          color: isCorrect
                              ? AppTheme.correctGreen
                              : AppTheme.borderGrey,
                          width: isCorrect ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${index + 1}. ",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: Text(
                                currentQuestion.options[index],
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Question navigation bar for all questions
            QuestionNavBar(
              totalQuestions: state.questions.length,
              currentIndex: _currentIndex,
              answerStates: state.selectedAnswers,
              onQuestionTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
