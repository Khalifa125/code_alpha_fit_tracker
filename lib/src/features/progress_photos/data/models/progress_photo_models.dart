import 'dart:typed_data';

class ProgressPhoto {
  final String id;
  final DateTime date;
  final String? imagePath;
  final Uint8List? imageData;
  final String? category; // front, side, back
  final String? note;
  final double? weight;

  ProgressPhoto({
    required this.id,
    required this.date,
    this.imagePath,
    this.imageData,
    this.category,
    this.note,
    this.weight,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'imagePath': imagePath,
    'category': category,
    'note': note,
    'weight': weight,
  };

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) => ProgressPhoto(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    imagePath: json['imagePath'] as String?,
    category: json['category'] as String?,
    note: json['note'] as String?,
    weight: json['weight'] as double?,
  );
}

class ProgressComparison {
  final ProgressPhoto before;
  final ProgressPhoto after;

  ProgressComparison({required this.before, required this.after});

  int get daysDiff => after.date.difference(before.date).inDays;
  double? get weightDiff => after.weight != null && before.weight != null 
      ? after.weight! - before.weight! : null;
}