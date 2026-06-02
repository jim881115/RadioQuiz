import 'package:flutter/material.dart';
import 'package:radioquiz/core/theme/app_theme.dart';

/// A horizontal, scrollable question-number navigation bar.
///
/// Displays one cell per question. The colour indicates its status:
///   - blue  → current question
///   - green → answered (or answered correctly when [isCorrectAnswers] is set)
///   - red   → answered incorrectly (only when [isCorrectAnswers] is set)
///   - grey  → unanswered
///
/// When [isCorrectAnswers] is provided, green/red distinguish correct/wrong
/// answers instead of the default "answered vs unanswered" logic.
/// [isCorrectAnswers] must have the same length as [answerStates].
///
/// Tapping a cell jumps to that question via [onQuestionTap].
class QuestionNavBar extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final List<int?> answerStates;
  final void Function(int index) onQuestionTap;

  /// Whether each answered question was correct.
  ///
  /// When provided, cells use green for correct and red for incorrect.
  /// When `null`, all answered cells are green.
  final List<bool>? isCorrectAnswers;

  const QuestionNavBar({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answerStates,
    required this.onQuestionTap,
    this.isCorrectAnswers,
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
          } else if (isAnswered && isCorrectAnswers != null) {
            // Results review mode: distinguish correct vs wrong.
            cellColor = isCorrectAnswers![index]
                ? AppTheme.correctGreen
                : AppTheme.wrongRed;
          } else if (isAnswered) {
            // Quiz mode: all answered are green.
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
