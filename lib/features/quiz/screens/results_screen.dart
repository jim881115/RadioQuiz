import 'package:flutter/material.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/core/constants/app_constants.dart';

class ResultsScreen extends StatefulWidget {
  final String level;
  final List<Question> questions;
  final List<int?> selectedAnswers;

  const ResultsScreen({
    super.key,
    required this.level,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _currentIndex = 0;
  int _correctCount = 0;
  late List<Question> _incorrectQuestions;
  late List<int?> _incorrectAnswers;
  late int _passingScore;
  late bool _isPassed;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _filterIncorrectQuestions();
    _caculatePass();
  }

  void _filterIncorrectQuestions() {
    _correctCount = 0;
    _incorrectQuestions = [];
    _incorrectAnswers = [];

    for (int i = 0; i < widget.questions.length; i++) {
      if (widget.selectedAnswers[i] != widget.questions[i].answerIndex) {
        _incorrectQuestions.add(widget.questions[i]);
        _incorrectAnswers.add(widget.selectedAnswers[i]);
      }
      else {
        _correctCount++;
      }
    }
  }

  void _caculatePass() {
    _passingScore = AppConstants.quizPassingScore[widget.level] ?? widget.questions.length;
    _isPassed = _correctCount >= _passingScore;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _incorrectQuestions[_currentIndex];
    final selectedAnswer = _incorrectAnswers[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("答題結果")),
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
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: "答對題數: ",
                      ),
                      TextSpan(
                        text: "$_correctCount",
                        style: TextStyle(
                          color: _isPassed ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: " / ${widget.questions.length}",
                      ),
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
                // 顯示目前第幾題
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.shade100,
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${_incorrectQuestions.length}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // 回到主畫面按鈕
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 顯示題目
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),

            // 顯示題目圖片（如果有）
            if (currentQuestion.hasImage)
              Image.asset(
                currentQuestion.imagePath ?? '',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              )
            else
              const SizedBox(height: 40), // 空間預留

            // 顯示選項
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
                            ? (isCorrect ? Colors.green.shade100 : Colors.red.shade100)
                            : null,
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.grey.shade400,
                          width: isCorrect ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${index + 1}. ",
                              style: const TextStyle(fontSize: 18),
                            ),
                            Expanded(
                              child: Text(
                                currentQuestion.options[index],
                                style: const TextStyle(fontSize: 18),
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

            // 上一題 & 下一題按鈕
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 上一題
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

                // 下一題
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