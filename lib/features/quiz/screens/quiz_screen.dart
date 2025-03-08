import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';
import 'package:radioquiz/data/models/question.dart';
import 'package:radioquiz/features/quiz/viewmodels/quiz_viewmodel.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String level;

  const QuizScreen({super.key, required this.level});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late List<Question> questions = [];
  late Map<String, String> images = {};
  late double _screenWidth; // 螢幕寬度
  late double _screenHeight; // 螢幕高度
  int _currentIndex = 0;
  late Timer _timer;
  int _remainingTime = AppConstants.quizDuration;
  late List<int?> _selectedAnswers = []; // 記錄每題的選擇狀態
  bool _hasUnanswered = true;

  @override
  void initState() {
    super.initState();

    _loadData();
    _startTimer();
  }

  Future<void> _loadData() async {
    await ref.read(quizControllerProvider.notifier).load(widget.level);
    // 載入題目
    questions = ref.read(quizControllerProvider).questions;
    // 載入圖片
    images = ref.read(quizControllerProvider).imagePaths;
    debugPrint("images: $images");

    _selectedAnswers = List<int?>.filled(questions.length, null);
    _hasUnanswered = true;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        // 時間結束，跳轉到結果頁
        Navigator.pushReplacementNamed(
          context,
          '/results',
          arguments: {
            'level': widget.level,
            'questions': questions,
            'selectedAnswers': _selectedAnswers,
            'images': images,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 等待資料載入，顯示轉圈圈
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[_currentIndex];
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;

    _screenWidth = UIConstants().screenWidth;
    _screenHeight = UIConstants().screenHeight;
    _hasUnanswered = _selectedAnswers.any((answer) => answer == null);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: UIConstants().screenWidth * 0.2,
        leading: SvgPicture.asset(AppConstants.iconPath),
        title: Text(
          "${widget.level[0].toUpperCase()}${widget.level.substring(1)} Radio Quiz",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 最上方資訊區
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 顯示第幾題
                Container(
                  padding: const EdgeInsets.all(14),
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.shade100,
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${questions.length}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                // 顯示倒計時（置中）
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red.shade100,
                      ),
                      child: Text(
                        "$minutes:${seconds.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                // 結束作答按鈕
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    backgroundColor: Colors.green.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _hasUnanswered
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("提醒"),
                              content: const Text("您還有未作答的題目，請完成所有題目後再提交"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("確定"),
                                ),
                              ],
                            ),
                          );
                        }
                      : () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/results',
                            arguments: {
                              'level': widget.level,
                              'questions': questions,
                              'selectedAnswers': _selectedAnswers,
                              'images': images,
                            },
                          );
                        },
                  child: const Text(
                    "結束作答",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 題目文字
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
                images[currentQuestion.image] ?? '',
                fit: BoxFit.contain,
                height: _screenHeight * 0.33,
                width: double.infinity,
              )
            else
              const SizedBox(height: 40), // 空間預留

            // 選項
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 選項號碼部分
                        Text(
                          "${index + 1}. ",
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        // 選項內容部分，處理多行對齊
                        Expanded(
                          child: Text(
                            currentQuestion.options[index],
                            style: const TextStyle(fontSize: 16, height: 1.3),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 選擇答案按鈕
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAnswers[_currentIndex] == index;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.lightBlue
                            : Colors.white70, // 改變顏色
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedAnswers[_currentIndex] = index; // 記錄選擇的答案
                        });
                      },
                      child: Text(
                        (index + 1).toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // 上一題和下一題按鈕
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
                          : null, // 第一題禁用
                      child: const Text("上一題"),
                    ),

                    // 下一題
                    ElevatedButton(
                      onPressed: _currentIndex < questions.length - 1
                          ? () {
                              setState(() {
                                _currentIndex++;
                              });
                            }
                          : null, // 最後一題禁用
                      child: const Text("下一題"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
