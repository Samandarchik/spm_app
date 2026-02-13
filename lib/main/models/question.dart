class Question {
  final String id;
  final String question;
  final List<String> options;
  final String? imageUrl;

  Question({
    required this.id,
    required this.question,
    required this.options,
    this.imageUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      imageUrl: json['imageUrl'],
    );
  }
}
