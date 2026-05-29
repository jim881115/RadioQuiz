import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:radioquiz/features/quiz/viewmodels/quiz_viewmodel.dart';
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
  late List<Question> _incorrectQuestions;
  late List<int?> _incorrectAnswers;
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
    _incorrectQuestions = [];
    _incorrectAnswers = [];

    for (int i = 0; i < state.questions.length; i++) {
      if (state.selectedAnswers[i] != state.questions[i].answerIndex) {
        _incorrectQuestions.add(state.questions[i]);
        _incorrectAnswers.add(state.selectedAnswers[i]);
      } else {
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

    // All questions correct case
    if (_incorrectQuestions.isEmpty) {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              const Text(
                "恭喜全對！",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, ModalRoute.withName('/')),
                child: const Text("回主頁"),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _incorrectQuestions[_currentIndex];
    final selectedAnswer = _incorrectAnswers[_currentIndex];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      const TextSpan(text: "答對題數: "),
                      TextSpan(
                        text: "$_correctCount",
                        style: TextStyle(
                          color: _isPassed ? Colors.green : Colors.red,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.shade100,
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${_incorrectQuestions.length}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    backgroundColor: Colors.green.shade400,
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
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),
            if (currentQuestion.hasImage)
              Image.asset(
                state.imagePaths[currentQuestion.image] ?? '',
                fit: BoxFit.contain,
                height: _screenHeight * 0.25,
                width: double.infinity,
              )
            else
              const SizedBox(height: 40),
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
                                ? Colors.green.shade100
                                : Colors.red.shade100)
                            : null,
                        border: Border.all(
                          color:
                              isCorrect ? Colors.green : Colors.grey.shade400,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentIndex > 0
                      ? () {
                          setState(() {
                            _currentIndex--;
                          });
                        }
                      : null,
                  child: const Text("上一題"),
                ),
                ElevatedButton(
                  onPressed: _currentIndex < _incorrectQuestions.length - 1
                      ? () {
                          setState(() {
                            _currentIndex++;
                          });
                        }
                      : null,
                  child: const Text("下一題"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
