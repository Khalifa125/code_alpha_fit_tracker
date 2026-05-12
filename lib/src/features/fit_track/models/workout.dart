class Exercise {
  final String id;
  final String name;
  final String description;
  final int durationSeconds;
  final String imageUrl;
  final String muscleGroup;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.durationSeconds,
    required this.imageUrl,
    required this.muscleGroup,
    this.instructions = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'durationSeconds': durationSeconds,
    'imageUrl': imageUrl,
    'muscleGroup': muscleGroup,
    'instructions': instructions,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    durationSeconds: json['durationSeconds'] as int,
    imageUrl: json['imageUrl'] as String,
    muscleGroup: json['muscleGroup'] as String,
    instructions: (json['instructions'] as List?)?.cast<String>() ?? [],
  );
}

class Workout {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final String difficulty;
  final List<Exercise> exercises;
  final DateTime createdAt;
  final bool isCompleted;

  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.difficulty,
    required this.exercises,
    required this.createdAt,
    this.isCompleted = false,
  });

  int get totalExercises => exercises.length;
  
  int get totalDuration => exercises.fold(0, (sum, e) => sum + e.durationSeconds);

  Workout copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    String? difficulty,
    List<Exercise>? exercises,
    DateTime? createdAt,
    bool? isCompleted,
  }) => Workout(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    difficulty: difficulty ?? this.difficulty,
    exercises: exercises ?? this.exercises,
    createdAt: createdAt ?? this.createdAt,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'durationMinutes': durationMinutes,
    'difficulty': difficulty,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    durationMinutes: json['durationMinutes'] as int,
    difficulty: json['difficulty'] as String,
    exercises: (json['exercises'] as List).map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

class WorkoutSession {
  final String id;
  final Workout workout;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int currentExerciseIndex;
  final int elapsedSeconds;
  final bool isPaused;
  final bool isCompleted;

  WorkoutSession({
    required this.id,
    required this.workout,
    required this.startedAt,
    this.completedAt,
    this.currentExerciseIndex = 0,
    this.elapsedSeconds = 0,
    this.isPaused = false,
    this.isCompleted = false,
  });

  Exercise? get currentExercise => 
    currentExerciseIndex < workout.exercises.length 
      ? workout.exercises[currentExerciseIndex] 
      : null;

  double get progress => workout.exercises.isEmpty 
    ? 0 
    : currentExerciseIndex / workout.exercises.length;

  WorkoutSession copyWith({
    String? id,
    Workout? workout,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentExerciseIndex,
    int? elapsedSeconds,
    bool? isPaused,
    bool? isCompleted,
  }) => WorkoutSession(
    id: id ?? this.id,
    workout: workout ?? this.workout,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    isPaused: isPaused ?? this.isPaused,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}
