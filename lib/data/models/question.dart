class Question {
  final int id;
  final String type;
  final int questionId;
  final String question;
  final List<String> options;
  final int answerIndex;
  final bool hasImage;
  final String? imagePath;

  Question({
    required this.id,
    required this.type,
    required this.questionId,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.hasImage,
    this.imagePath,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      type: map['category'],
      questionId: map['question_id'],
      question: map['question'],
      options: [
        map['option1'],
        map['option2'],
        map['option3'],
        map['option4'],
      ],
      answerIndex: map['answer'],
      hasImage: map['has_image'] == 1,
      imagePath: map['image_path'],
    );
  }
}