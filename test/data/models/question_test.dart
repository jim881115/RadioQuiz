import 'package:flutter_test/flutter_test.dart';
import 'package:radioquiz/data/models/question.dart';

void main() {
  group('Question.fromMap', () {
    /// Creates a base valid map that can be overridden per test case.
    Map<String, dynamic> baseMap({
      int hasImage = 1,
      String? image = 'level1_image.png',
    }) {
      return {
        'id': 1,
        'category': '無線電規章與相關法規',
        'question_id': 101,
        'question': '下列何者為業餘無線電人員得使用之發射頻率？',
        'option1': 'Option A',
        'option2': 'Option B',
        'option3': 'Option C',
        'option4': 'Option D',
        'answer': 0,
        'has_image': hasImage,
        'image': image,
      };
    }

    test('parses a complete map with image correctly', () {
      final map = baseMap();
      final question = Question.fromMap(map);

      expect(question.id, 1);
      expect(question.type, '無線電規章與相關法規');
      expect(question.questionId, 101);
      expect(question.question, '下列何者為業餘無線電人員得使用之發射頻率？');
      expect(question.answerIndex, 0);
      expect(question.hasImage, isTrue);
      expect(question.image, 'level1_image.png');
    });

    test('sets hasImage to false and image to null when has_image is 0', () {
      final map = baseMap(hasImage: 0, image: null);
      final question = Question.fromMap(map);

      expect(question.hasImage, isFalse);
      expect(question.image, isNull);
    });

    test('options always contains exactly 4 choices', () {
      final map = baseMap();
      final question = Question.fromMap(map);

      expect(question.options.length, 4);
      expect(question.options[0], 'Option A');
      expect(question.options[1], 'Option B');
      expect(question.options[2], 'Option C');
      expect(question.options[3], 'Option D');
    });

    test('parses integer fields correctly as int type', () {
      final map = baseMap();
      final question = Question.fromMap(map);

      expect(question.id, isA<int>());
      expect(question.questionId, isA<int>());
      expect(question.answerIndex, isA<int>());
    });
  });
}
