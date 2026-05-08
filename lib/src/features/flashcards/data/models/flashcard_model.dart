import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

part 'flashcard_model.g.dart';

@HiveType(typeId: 50)
class FlashcardModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final String answer;

  @HiveField(3)
  final String topic;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool isLearned;

  @HiveField(6)
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
