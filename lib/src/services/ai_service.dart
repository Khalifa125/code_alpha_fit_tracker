import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-20250514';
  
  final String _apiKey;
  
  AIService() : _apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
  
  Future<Map<String, dynamic>> generateWorkoutPlan({
    required String goal,
    required int days,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY not found in .env file');
    }
    
    final prompt = '''
Generate a $days-day workout plan for: $goal.

Return ONLY a valid JSON object with this structure:
{
  "title": "Plan title",
  "duration": $days,
  "goal": "$goal",
  "days": [
    {
      "day": 1,
      "focus": "Focus area",
      "warmup": "Warmup description",
      "exercises": [
        {"name": "Exercise name", "sets": 3, "reps": 12, "rest": "60 sec"}
      ],
      "cooldown": "Cooldown description"
    }
  ]
}

Make the plan practical and progressive.
''';
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 4096,
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;
        final jsonStr = content.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate workout plan: $e');
    }
  }
  
  Future<String> analyzeProgress(List<Map<String, dynamic>> metrics) async {
    if (_apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY not found in .env file');
    }
    
    final prompt = '''
Analyze this fitness progress data:
${metrics.map((m) => '- ${m['label']}: ${m['value']}').join('\n')}

Provide insights on:
1. Progress trends
2. Areas of improvement
3. Recommendations

Keep it concise and motivational.
''';
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to analyze progress: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> suggestMeal({
    required int calories,
    required String goal,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY not found in .env file');
    }
    
    final prompt = '''
Suggest 5 meals for a $calories-calorie diet with goal: $goal.

Return ONLY a valid JSON array:
[
  {"name": "Meal name", "type": "breakfast/lunch/dinner/snack", "calories": 400, "protein": 30, "carbs": 40, "fat": 15, "description": "Brief description"}
]

Make meals nutritious and goal-appropriate.
''';
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 2048,
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;
        final jsonStart = content.indexOf('[');
        final jsonEnd = content.lastIndexOf(']') + 1;
        final jsonStr = content.substring(jsonStart, jsonEnd);
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to suggest meals: $e');
    }
  }
  
  Future<String> generateMotivation({
    required int currentStreak,
    required int totalWorkouts,
    required int weeklyGoal,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY not found in .env file');
    }
    
    final prompt = '''
Generate a short, powerful motivational message for a fitness tracker user:
- Current streak: $currentStreak days
- Total workouts: $totalWorkouts
- Weekly goal: $weeklyGoal workouts

Make it concise (1-2 sentences), energetic, and personalized.
Use emojis sparingly.
''';
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 256,
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['content'][0]['text'] as String).trim();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate motivation: $e');
    }
  }
  
  Future<List<Flashcard>> generateFlashcards({
    required String topic,
    int count = 10,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY not found in .env file');
    }
    
    final prompt = '''
Generate $count flashcards about "$topic".
Return ONLY a valid JSON array with this exact structure:
[
  {"question": "Question text here", "answer": "Answer text here"},
  ...
]

Make the flashcards educational, clear, and suitable for learning.
''';
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 4096,
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;
        final jsonStart = content.indexOf('[');
        final jsonEnd = content.lastIndexOf(']') + 1;
        final jsonStr = content.substring(jsonStart, jsonEnd);
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        
        return jsonList.map((item) => Flashcard(
          question: item['question'] as String,
          answer: item['answer'] as String,
          topic: topic,
          createdAt: DateTime.now(),
        )).toList();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate flashcards: $e');
    }
  }
  
  Future<String> askQuestion({
    required String question,
    String? context,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY not found in .env file');
    }
    
    final prompt = context != null
        ? 'Context: $context\n\nQuestion: $question'
        : question;
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }
}

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String topic;
  final DateTime createdAt;
  bool isLearned;
  
  Flashcard({
    required this.question,
    required this.answer,
    required this.topic,
    required this.createdAt,
    String? id,
    this.isLearned = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'topic': topic,
    'createdAt': createdAt.toIso8601String(),
    'isLearned': isLearned,
  };
  
  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    question: json['question'],
    answer: json['answer'],
    topic: json['topic'],
    createdAt: DateTime.parse(json['createdAt']),
    isLearned: json['isLearned'] ?? false,
  );
}
    
    final prompt = '''
Generate $count flashcards about "$topic".
Return ONLY a valid JSON array with this exact structure:
[
  {"question": "Question text here", "answer": "Answer text here"},
  ...
]

Make the flashcards educational, clear, and suitable for learning.
''';
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 4096,
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;
        final jsonStart = content.indexOf('[');
        final jsonEnd = content.lastIndexOf(']') + 1;
        final jsonStr = content.substring(jsonStart, jsonEnd);
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        
        return jsonList.map((item) => Flashcard(
          question: item['question'] as String,
          answer: item['answer'] as String,
          topic: topic,
          createdAt: DateTime.now(),
        )).toList();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate flashcards: $e');
    }
  }
  
  Future<String> askQuestion({
    required String question,
    String? context,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY not found in .env file');
    }
    
    final prompt = context != null
        ? 'Context: $context\n\nQuestion: $question'
        : question;
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }
}

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String topic;
  final DateTime createdAt;
  bool isLearned;
  
  Flashcard({
    required this.question,
    required this.answer,
    required this.topic,
    required this.createdAt,
    String? id,
    this.isLearned = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'topic': topic,
    'createdAt': createdAt.toIso8601String(),
    'isLearned': isLearned,
  };
  
  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    question: json['question'],
    answer: json['answer'],
    topic: json['topic'],
    createdAt: DateTime.parse(json['createdAt']),
    isLearned: json['isLearned'] ?? false,
  );
}
