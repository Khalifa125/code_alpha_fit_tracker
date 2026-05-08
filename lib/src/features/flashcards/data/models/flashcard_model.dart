class FlashcardModel {
  final String id;
  final String question;
  final String answer;
  final String topic;
  final DateTime createdAt;
  bool isLearned;
  final int? reviewCount;

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.topic,
    required this.createdAt,
    this.isLearned = false,
    this.reviewCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'topic': topic,
        'createdAt': createdAt.toIso8601String(),
        'isLearned': isLearned,
        'reviewCount': reviewCount,
      };

  factory FlashcardModel.fromJson(Map<String, dynamic> json) => FlashcardModel(
        id: json['id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        topic: json['topic'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isLearned: json['isLearned'] as bool? ?? false,
        reviewCount: json['reviewCount'] as int?,
      );
}