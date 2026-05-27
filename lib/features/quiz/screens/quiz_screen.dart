import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';
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
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizControllerProvider.notifier).load(widget.level);
    });
  }

  void _navigateToResults() {
    if (_navigated) return;
    _navigated = true;

    final state = ref.read(quizControllerProvider);
    Navigator.pushReplacementNamed(
      context,
      '/results',
      arguments: {
        'level': widget.level,
        'questions': state.questions,
        'selectedAnswers': state.selectedAnswers,
        'images': state.imagePaths,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // timeout force submit listener
    ref.listen(quizControllerProvider, (QuizState? prev, QuizState next) {
      if (prev != null && !prev.isCompleted && next.isCompleted) {
        _navigateToResults();
      }
    });

    final state = ref.watch(quizControllerProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('載入失敗：${state.error}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(quizControllerProvider.notifier)
                    .load(widget.level),
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = state.currentQuestion;
    final minutes = state.remainingTime ~/ 60;
    final seconds = state.remainingTime % 60;
    final screenHeight = UIConstants().screenHeight;
    final levelTitle =
        '${widget.level[0].toUpperCase()}${widget.level.substring(1)} Radio Quiz';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: UIConstants().screenWidth * 0.2,
        leading: SvgPicture.asset(AppConstants.iconPath),
        title: Text(
          levelTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // top bar
            _buildStatusBar(state, minutes, seconds),
            const SizedBox(height: 20),

            // question text
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),

            // question image (if exists)
            if (currentQuestion.hasImage)
              Image.asset(
                state.imagePaths[currentQuestion.image] ?? '',
                fit: BoxFit.contain,
                height: screenHeight * 0.33,
                width: double.infinity,
              )
            else
              const SizedBox(height: 40),

            // options
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${index + 1}. ",
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
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

            // answer buttons
            _buildAnswerButtons(state),

            // next/previous buttons
            _buildNavButtons(state),
          ],
        ),
      ),
    );
  }

  /// top bar: question index, countdown timer, submit button
  Widget _buildStatusBar(QuizState state, int minutes, int seconds) {
    final controller = ref.read(quizControllerProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // question index
        Container(
          padding: const EdgeInsets.all(14),
          width: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.blue.shade100,
          ),
          child: Text(
            "${state.currentIndex + 1} / ${state.totalQuestions}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        // countdown timer
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
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        // submit button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _showSubmitDialog(context, state, controller),
          child: const Text(
            "結束作答",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// submit check dialog
  void _showSubmitDialog(
      BuildContext context, QuizState state, QuizController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("提醒"),
        content: Text(
          state.hasUnanswered
              ? "您還有未作答的題目，確定要結束作答並提交嗎？"
              : "您已完成所有題目，確定要結束作答並提交嗎？",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    controller.submit();
                  },
                  child: const Text("是"),
                ),
              ),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("否"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// answer buttons (1~4)
  Widget _buildAnswerButtons(QuizState state) {
    final controller = ref.read(quizControllerProvider.notifier);
    return Column(
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
            final isSelected =
                state.selectedAnswers[state.currentIndex] == index;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.lightBlue : Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => controller.selectAnswer(index),
              child: Text(
                (index + 1).toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// next/previous buttons
  Widget _buildNavButtons(QuizState state) {
    final controller = ref.read(quizControllerProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed:
              state.currentIndex > 0 ? () => controller.goToPrevious() : null,
          child: const Text("上一題"),
        ),
        ElevatedButton(
          onPressed: state.currentIndex < state.totalQuestions - 1
              ? () => controller.goToNext()
              : null,
          child: const Text("下一題"),
        ),
      ],
    );
  }
}
