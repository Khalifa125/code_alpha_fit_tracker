import 'dart:math';
import 'package:fit_tracker/src/features/fit_track/models/workout.dart';

class WorkoutGenerator {
  static final _random = Random();

  // Exercise database
  static final List<Exercise> _exercises = [
    // Warm-up exercises
    Exercise(
      id: 'jumping_jacks',
      name: 'Jumping Jacks',
      description: 'A full-body cardio exercise',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/jumping_jacks.png',
      muscleGroup: 'full_body',
      instructions: ['Stand with feet together', 'Jump and spread legs', 'Jump back to start', 'Repeat'],
    ),
    Exercise(
      id: 'high_knees',
      name: 'High Knees',
      description: 'Running in place with high knees',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/high_knees.png',
      muscleGroup: 'legs',
      instructions: ['Stand tall', 'Lift knees alternately', 'Pump arms', 'Keep core tight'],
    ),
    Exercise(
      id: 'arm_circles',
      name: 'Arm Circles',
      description: 'Warm up your shoulders',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/arm_circles.png',
      muscleGroup: 'shoulders',
      instructions: ['Extend arms sideways', 'Make circular motions', 'Increase size', 'Reverse direction'],
    ),

    // Strength exercises
    Exercise(
      id: 'push_ups',
      name: 'Push-ups',
      description: 'Classic chest and arm exercise',
      durationSeconds: 45,
      imageUrl: 'assets/exercises/pushups.png',
      muscleGroup: 'chest',
      instructions: ['Start in plank position', 'Lower chest to ground', 'Push back up', 'Keep core engaged'],
    ),
    Exercise(
      id: 'squats',
      name: 'Squats',
      description: 'Build leg strength',
      durationSeconds: 45,
      imageUrl: 'assets/exercises/squats.png',
      muscleGroup: 'legs',
      instructions: ['Stand with feet shoulder-width', 'Lower hips back and down', 'Keep chest up', 'Push through heels'],
    ),
    Exercise(
      id: 'lunges',
      name: 'Lunges',
      description: 'Unilateral leg exercise',
      durationSeconds: 45,
      imageUrl: 'assets/exercises/lunges.png',
      muscleGroup: 'legs',
      instructions: ['Step forward', 'Lower back knee', 'Push back up', 'Alternate legs'],
    ),
    Exercise(
      id: 'plank',
      name: 'Plank',
      description: 'Core stabilization exercise',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/plank.png',
      muscleGroup: 'core',
      instructions: ['Forearms on ground', 'Body in straight line', 'Engage core', 'Hold position'],
    ),
    Exercise(
      id: 'mountain_climbers',
      name: 'Mountain Climbers',
      description: 'High-intensity core exercise',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/mountain_climbers.png',
      muscleGroup: 'core',
      instructions: ['Start in plank', 'Drive knees to chest', 'Alternate quickly', 'Keep hips low'],
    ),
    Exercise(
      id: 'burpees',
      name: 'Burpees',
      description: 'Full-body explosive exercise',
      durationSeconds: 45,
      imageUrl: 'assets/exercises/burpees.png',
      muscleGroup: 'full_body',
      instructions: ['Squat down, hands on floor', 'Jump feet back to plank', 'Do a push-up', 'Jump feet forward, then up'],
    ),
    Exercise(
      id: 'jump_squats',
      name: 'Jump Squats',
      description: 'Explosive leg exercise',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/jump_squats.png',
      muscleGroup: 'legs',
      instructions: ['Do a regular squat', 'Jump explosively', 'Land softly', 'Repeat'],
    ),
    Exercise(
      id: 'tricep_dips',
      name: 'Tricep Dips',
      description: 'Upper body exercise',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/tricep_dips.png',
      muscleGroup: 'arms',
      instructions: ['Hands on edge behind you', 'Lower body down', 'Push back up', 'Keep elbows close'],
    ),
    Exercise(
      id: 'bicycle_crunches',
      name: 'Bicycle Crunches',
      description: 'Core rotation exercise',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/bicycle_crunches.png',
      muscleGroup: 'core',
      instructions: ['Lie on back', 'Hands behind head', 'Bring elbow to knee', 'Alternate sides'],
    ),
    Exercise(
      id: 'glute_bridges',
      name: 'Glute Bridges',
      description: 'Glute activation',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/glute_bridges.png',
      muscleGroup: 'legs',
      instructions: ['Lie on back, knees bent', 'Squeeze glutes', 'Lift hips up', 'Hold at top'],
    ),
    Exercise(
      id: 'side_plank',
      name: 'Side Plank',
      description: 'Oblique exercise',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/side_plank.png',
      muscleGroup: 'core',
      instructions: ['Lie on side', 'Prop on forearm', 'Lift hips', 'Hold position'],
    ),
    Exercise(
      id: 'dead_bug',
      name: 'Dead Bug',
      description: 'Core stability',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/dead_bug.png',
      muscleGroup: 'core',
      instructions: ['Lie on back', 'Arms and legs up', 'Lower opposite limbs', 'Keep back flat'],
    ),
    Exercise(
      id: 'box_jumps',
      name: 'Box Jumps',
      description: 'Plyometric exercise',
      durationSeconds: 30,
      imageUrl: 'assets/exercises/box_jumps.png',
      muscleGroup: 'legs',
      instructions: ['Stand before box', 'Jump onto box', 'Land softly', 'Step down'],
    ),
  ];

  static List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return _exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  static List<Exercise> getExercisesByDifficulty(int durationMinutes, String fitnessLevel) {
    int exerciseCount = durationMinutes * 60 ~/ 40; // ~40 sec per exercise
    
    // Adjust based on fitness level
    if (fitnessLevel == 'beginner') {
      exerciseCount = (exerciseCount * 0.7).toInt();
    } else if (fitnessLevel == 'advanced') {
      exerciseCount = (exerciseCount * 1.3).toInt();
    }
    
    return _exercises.take(exerciseCount.clamp(3, 15)).toList();
  }

  static Workout generateWorkout({
    required String goal,
    required String fitnessLevel,
    required int availableMinutes,
  }) {
    final exercises = _selectExercises(goal, fitnessLevel, availableMinutes);
    final title = _generateTitle(goal, fitnessLevel);
    final difficulty = _getDifficulty(fitnessLevel);
    
    return Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _getDescription(goal, fitnessLevel),
      durationMinutes: availableMinutes,
      difficulty: difficulty,
      exercises: exercises,
      createdAt: DateTime.now(),
    );
  }

  static List<Exercise> _selectExercises(String goal, String fitnessLevel, int minutes) {
    // Select exercises based on goal
    List<Exercise> selected = [];
    
    if (goal == 'loseWeight') {
      // More cardio-focused
      selected = _exercises.where((e) => 
        e.muscleGroup == 'full_body' || e.muscleGroup == 'core'
      ).toList();
    } else if (goal == 'buildMuscle') {
      // More strength-focused  
      selected = _exercises.where((e) =>
        e.muscleGroup == 'chest' || e.muscleGroup == 'arms' || e.muscleGroup == 'legs'
      ).toList();
    } else {
      // Stay active - mix of everything
      selected = List.from(_exercises);
    }
    
    // Adjust count based on time
    int count = (minutes / 2).clamp(4, 12).toInt();
    
    // Adjust for fitness level
    if (fitnessLevel == 'beginner') {
      count = (count * 0.7).toInt().clamp(3, 10);
    } else if (fitnessLevel == 'advanced') {
      count = (count * 1.2).toInt().clamp(5, 15);
    }
    
    // Shuffle and take needed amount
    selected.shuffle(_random);
    return selected.take(count).toList();
  }

  static String _generateTitle(String goal, String fitnessLevel) {
    final titles = {
      'loseWeight': {
        'beginner': 'Light Cardio Blast',
        'intermediate': 'Fat Burn Circuit',
        'advanced': 'HIIT Power Burn',
      },
      'buildMuscle': {
        'beginner': 'Foundation Building',
        'intermediate': 'Muscle Builder',
        'advanced': 'Power Strength',
      },
      'stayActive': {
        'beginner': 'Gentle Movement',
        'intermediate': 'Active Energy',
        'advanced': 'Full Body Flow',
      },
    };
    
    return titles[goal]?[fitnessLevel] ?? 'Daily Workout';
  }

  static String _getDifficulty(String fitnessLevel) {
    switch (fitnessLevel) {
      case 'beginner':
        return 'Easy';
      case 'intermediate':
        return 'Medium';
      case 'advanced':
        return 'Hard';
      default:
        return 'Medium';
    }
  }

  static String _getDescription(String goal, String fitnessLevel) {
    switch (goal) {
      case 'loseWeight':
        return 'High-intensity workout designed to maximize calorie burn and improve cardiovascular fitness.';
      case 'buildMuscle':
        return 'Strength-focused workout to build muscle and increase overall body strength.';
      case 'stayActive':
        return 'Balanced workout to keep you active and maintain your fitness level.';
      default:
        return 'A personalized workout based on your goals and fitness level.';
    }
  }

  // Quick Workout - generate a fast workout
  static Workout generateQuickWorkout(int minutes) {
    final exercises = _exercises.take((minutes / 2).clamp(3, 8).toInt()).toList();
    
    return Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$minutes Minute Quick Workout',
      description: 'A fast, efficient workout you can do anywhere.',
      durationMinutes: minutes,
      difficulty: 'Medium',
      exercises: exercises,
      createdAt: DateTime.now(),
    );
  }
}
