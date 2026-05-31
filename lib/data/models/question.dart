/// Represents a single quiz question from the database.
///
/// Maps to a row in the `level1`, `level2`, or `level3` tables.
/// Use [fromMap] to create an instance from a database query result.
class Question {
  final int id;
  final String type;
  final int questionId;
  final String question;
  final List<String> options;
  final int answerIndex;
  final bool hasImage;
  final String? image;

  const Question({
    required this.id,
    required this.type,
    required this.questionId,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.hasImage,
    this.image,
  });

  /// Creates a [Question] from a database row [map].
  ///
  /// The map should contain keys:
  /// `id`, `category`, `question_id`, `question`,
  /// `option1`–`option4`, `answer`, `has_image`, and optionally `image`.
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int,
      type: map['category'] as String,
      questionId: map['question_id'] as int,
      question: map['question'] as String,
      options: [
        map['option1'] as String,
        map['option2'] as String,
        map['option3'] as String,
        map['option4'] as String,
      ],
      answerIndex: map['answer'] as int,
      hasImage: map['has_image'] == 1,
      image: map['image'] as String?,
    );
  }
}
