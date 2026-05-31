import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/core/constants/app_constants.dart';

/// Expected total questions per level.
const Map<String, int> _expectedTotals = {
  'level1': 50,
  'level2': 40,
  'level3': 35,
};

void main() {
  group('AppConstants.questionDistribution', () {
    test('level1 question sum equals 50', () {
      final total = AppConstants.questionDistribution['level1']?.values
          .fold<int>(0, (sum, v) => sum + v);
      expect(total, _expectedTotals['level1']);
    });

    test('level2 question sum equals 40', () {
      final total = AppConstants.questionDistribution['level2']?.values
          .fold<int>(0, (sum, v) => sum + v);
      expect(total, _expectedTotals['level2']);
    });

    test('level3 question sum equals 35', () {
      final total = AppConstants.questionDistribution['level3']?.values
          .fold<int>(0, (sum, v) => sum + v);
      expect(total, _expectedTotals['level3']);
    });
  });

  group('AppConstants.quizPassingScore', () {
    test('passing score does not exceed total questions for level1', () {
      final total = AppConstants.questionDistribution['level1']!.values
          .fold<int>(0, (sum, v) => sum + v);
      final passScore = AppConstants.quizPassingScore['level1']!;
      expect(passScore, lessThanOrEqualTo(total));
    });

    test('passing score does not exceed total questions for level2', () {
      final total = AppConstants.questionDistribution['level2']!.values
          .fold<int>(0, (sum, v) => sum + v);
      final passScore = AppConstants.quizPassingScore['level2']!;
      expect(passScore, lessThanOrEqualTo(total));
    });

    test('passing score does not exceed total questions for level3', () {
      final total = AppConstants.questionDistribution['level3']!.values
          .fold<int>(0, (sum, v) => sum + v);
      final passScore = AppConstants.quizPassingScore['level3']!;
      expect(passScore, lessThanOrEqualTo(total));
    });
  });

  group('AppConstants level name consistency', () {
    test('all levels in questionDistribution exist in quizPassingScore', () {
      for (final level in AppConstants.questionDistribution.keys) {
        expect(AppConstants.quizPassingScore.containsKey(level), isTrue,
            reason: 'Level $level is missing from quizPassingScore');
      }
    });

    test('all levels in quizPassingScore exist in questionDistribution', () {
      for (final level in AppConstants.quizPassingScore.keys) {
        expect(AppConstants.questionDistribution.containsKey(level), isTrue,
            reason: 'Level $level is missing from questionDistribution');
      }
    });
  });
}
