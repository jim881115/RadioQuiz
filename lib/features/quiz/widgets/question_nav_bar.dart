import 'package:flutter/material.dart';
import 'package:radioquiz/core/theme/app_theme.dart';

/// A horizontal, scrollable question-number navigation bar.
///
/// Displays one cell per question. The colour indicates its status:
///   - grey  → unanswered
///   - green → answered
///   - blue  → currently viewed question
///
/// Tapping a cell jumps to that question via [onQuestionTap].
class QuestionNavBar extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final List<int?> answerStates;
  final void Function(int index) onQuestionTap;

  const QuestionNavBar({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answerStates,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalQuestions,
        itemBuilder: (context, index) {
          final bool isCurrent = index == currentIndex;
          final bool isAnswered = answerStates[index] != null;

          Color cellColor;
          if (isCurrent) {
            cellColor = AppTheme.selectedBlue;
          } else if (isAnswered) {
            cellColor = AppTheme.correctGreen;
          } else {
            cellColor = AppTheme.borderGrey;
          }

          return GestureDetector(
            onTap: () => onQuestionTap(index),
            child: Container(
              width: 40,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color:
                        isCurrent || isAnswered ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
