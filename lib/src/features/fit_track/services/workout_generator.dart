import 'dart:math';
import 'package:fit_tracker/src/features/fit_track/models/workout.dart';

class WorkoutGenerator {
  static final _random = Random();

  static final List<Exercise> _exercises = [
    // ═══ WARM-UP / MOBILITY (5) ═══
    Exercise(id: 'jumping_jacks', name: 'Jumping Jacks', description: 'Full-body cardio warm-up. Increases heart rate and activates multiple muscle groups.', durationSeconds: 30, imageUrl: 'assets/exercises/jumping_jacks.png', muscleGroup: 'full_body', instructions: ['Stand with feet together, arms at sides', 'Jump while spreading legs and raising arms overhead', 'Jump back to starting position', 'Maintain a steady rhythm']),
    Exercise(id: 'high_knees', name: 'High Knees', description: 'Dynamic warm-up that activates hip flexors and elevates heart rate quickly.', durationSeconds: 30, imageUrl: 'assets/exercises/high_knees.png', muscleGroup: 'legs', instructions: ['Stand tall with feet hip-width apart', 'Drive right knee toward chest', 'Alternate quickly with left knee', 'Pump arms for momentum', 'Land softly on mid-foot']),
    Exercise(id: 'arm_circles', name: 'Arm Circles', description: 'Mobilizes shoulder joints and warms up the rotator cuff.', durationSeconds: 30, imageUrl: 'assets/exercises/arm_circles.png', muscleGroup: 'shoulders', instructions: ['Extend arms straight out to sides', 'Make small circular motions', 'Gradually increase circle size', 'Reverse direction after 15 seconds']),
    Exercise(id: 'torso_twists', name: 'Torso Twists', description: 'Loosens up the spine and activates core muscles for rotation.', durationSeconds: 30, imageUrl: '', muscleGroup: 'core', instructions: ['Stand with feet shoulder-width apart', 'Raise arms to chest height', 'Twist torso to the right', 'Twist to the left', 'Keep hips facing forward']),
    Exercise(id: 'leg_swings', name: 'Leg Swings', description: 'Dynamic hamstring and hip flexor stretch. Prepares legs for explosive movement.', durationSeconds: 30, imageUrl: '', muscleGroup: 'legs', instructions: ['Hold onto a wall for support', 'Swing right leg forward and backward', 'Keep torso upright', 'Gradually increase range of motion', 'Switch to left leg']),

    // ═══ CHEST (5) ═══
    Exercise(id: 'push_ups', name: 'Push-ups', description: 'The gold standard chest exercise. Builds upper body pushing strength.', durationSeconds: 45, imageUrl: 'assets/exercises/pushups.png', muscleGroup: 'chest', instructions: ['Start in high plank, hands shoulder-width apart', 'Lower chest toward the ground, elbows at 45°', 'Push through palms to return to start', 'Keep core engaged, body in straight line', 'Full range of motion for best results']),
    Exercise(id: 'wide_push_ups', name: 'Wide Push-ups', description: 'Emphasizes the outer chest and shoulders by using a wider hand placement.', durationSeconds: 45, imageUrl: '', muscleGroup: 'chest', instructions: ['Hands placed wider than shoulder-width', 'Lower chest toward the ground', 'Push back up explosively', 'Focus on squeezing chest at the top']),
    Exercise(id: 'diamond_push_ups', name: 'Diamond Push-ups', description: 'Targets the triceps and inner chest by bringing hands close together.', durationSeconds: 40, imageUrl: 'assets/exercises/diamond_pushups.png', muscleGroup: 'arms', instructions: ['Form a diamond shape with thumbs and index fingers', 'Lower chest toward hands', 'Keep elbows close to body', 'Push back up with triceps strength']),
    Exercise(id: 'decline_push_ups', name: 'Decline Push-ups', description: 'Increases upper chest activation by elevating the feet.', durationSeconds: 40, imageUrl: '', muscleGroup: 'chest', instructions: ['Place feet on an elevated surface (chair/bench)', 'Hands on ground, body at angle', 'Lower chest toward ground', 'Push back up, focusing on upper chest']),
    Exercise(id: 'pike_push_ups', name: 'Pike Push-ups', description: 'Builds shoulder strength and prepares for handstand push-ups.', durationSeconds: 40, imageUrl: 'assets/exercises/pike_pushups.png', muscleGroup: 'shoulders', instructions: ['Hinge at hips, hands and feet on ground', 'Body forms an inverted V shape', 'Lower head toward ground between hands', 'Push back up, keeping hips high']),

    // ═══ BACK (6) ═══
    Exercise(id: 'superman_hold', name: 'Superman Hold', description: 'Strengthens the entire posterior chain: lower back, glutes, and hamstrings.', durationSeconds: 30, imageUrl: '', muscleGroup: 'back', instructions: ['Lie face down with arms extended overhead', 'Lift arms, chest, and legs off the ground', 'Hold at the top, squeezing lower back', 'Lower slowly with control']),
    Exercise(id: 'inverted_rows', name: 'Inverted Rows', description: 'Horizontal pulling movement that targets the mid-back and biceps.', durationSeconds: 40, imageUrl: '', muscleGroup: 'back', instructions: ['Set up under a sturdy table or low bar', 'Grip the edge, body straight from heels to shoulders', 'Pull chest toward the bar/table edge', 'Squeeze shoulder blades together at top', 'Lower with control']),
    Exercise(id: 'bird_dog', name: 'Bird Dog', description: 'Core stability exercise that also strengthens the lower back and glutes.', durationSeconds: 30, imageUrl: '', muscleGroup: 'back', instructions: ['Start on hands and knees', 'Extend right arm forward and left leg back', 'Hold for 2 seconds, keeping hips square', 'Return to start, switch sides', 'Move slowly and with control']),
    Exercise(id: 'swimmers', name: 'Prone Swimmers', description: 'Dynamic back extension exercise for upper back and shoulder stability.', durationSeconds: 30, imageUrl: '', muscleGroup: 'back', instructions: ['Lie face down, arms extended forward', 'Lift arms and legs slightly off ground', 'Flutter arms and legs alternately', 'Keep head in neutral position']),
    Exercise(id: 'reverse_plank', name: 'Reverse Plank', description: 'Opens the front body while strengthening the posterior chain.', durationSeconds: 30, imageUrl: '', muscleGroup: 'back', instructions: ['Sit with legs extended, hands behind hips', 'Press through palms and lift hips up', 'Keep body in straight line from shoulders to heels', 'Hold at the top, squeezing glutes']),
    Exercise(id: 'pull_up_negatives', name: 'Pull-Up Negatives', description: 'Build pull-up strength by focusing on the eccentric (lowering) phase.', durationSeconds: 40, imageUrl: '', muscleGroup: 'back', instructions: ['Jump or step up to top of pull-up position', 'Lower yourself as slowly as possible', 'Take 5-8 seconds to go from top to bottom', 'Reset and repeat']),

    // ═══ LEGS (8) ═══
    Exercise(id: 'squats', name: 'Bodyweight Squats', description: 'The foundation of lower body strength. Master this before adding weight.', durationSeconds: 45, imageUrl: 'assets/exercises/squats.png', muscleGroup: 'legs', instructions: ['Stand with feet shoulder-width apart', 'Send hips back and down like sitting in a chair', 'Lower until thighs are parallel to ground', 'Keep chest up and knees tracking over toes', 'Push through heels to stand']),
    Exercise(id: 'jump_squats', name: 'Jump Squats', description: 'Plyometric squat that builds explosive power and burns maximum calories.', durationSeconds: 35, imageUrl: 'assets/exercises/jump_squats.png', muscleGroup: 'legs', instructions: ['Perform a regular squat', 'Explode upward into a jump', 'Land softly with bent knees', 'Immediately descend into the next squat']),
    Exercise(id: 'lunges', name: 'Forward Lunges', description: 'Unilateral leg exercise that builds balance and leg symmetry.', durationSeconds: 45, imageUrl: 'assets/exercises/lunges.png', muscleGroup: 'legs', instructions: ['Step forward with right leg', 'Lower until both knees bend to 90°', 'Push through right heel to return', 'Alternate legs']),
    Exercise(id: 'reverse_lunges', name: 'Reverse Lunges', description: 'Easier on the knees than forward lunges while still building leg strength.', durationSeconds: 45, imageUrl: '', muscleGroup: 'legs', instructions: ['Step backward with right leg', 'Lower into lunge position', 'Push through left heel to return', 'Alternate between legs']),
    Exercise(id: 'side_lunges', name: 'Side Lunges', description: 'Targets adductors (inner thighs) and improves lateral stability.', durationSeconds: 40, imageUrl: '', muscleGroup: 'legs', instructions: ['Take a wide step to the right', 'Bend right knee, keeping left leg straight', 'Keep chest up and both feet flat', 'Push off right foot to return to center']),
    Exercise(id: 'glute_bridges', name: 'Glute Bridges', description: 'Essential glute activation exercise. Great for building hip strength.', durationSeconds: 40, imageUrl: 'assets/exercises/glute_bridges.png', muscleGroup: 'legs', instructions: ['Lie on back, knees bent, feet flat', 'Drive through heels, lift hips up', 'Squeeze glutes at the top for 2 seconds', 'Lower with control']),
    Exercise(id: 'calf_raises', name: 'Calf Raises', description: 'Isolation exercise for building defined calves and ankle strength.', durationSeconds: 30, imageUrl: '', muscleGroup: 'legs', instructions: ['Stand on the edge of a step', 'Lower heels below the step', 'Push up onto toes as high as possible', 'Pause at the top, then lower slowly']),
    Exercise(id: 'wall_sit', name: 'Wall Sit', description: 'Isometric leg exercise that builds incredible endurance in the quads.', durationSeconds: 45, imageUrl: '', muscleGroup: 'legs', instructions: ['Lean against a wall, slide down until thighs are parallel', 'Keep back flat against wall', 'Hold the position while breathing steadily', 'Keep weight in your heels']),

    // ═══ CORE (8) ═══
    Exercise(id: 'plank', name: 'Plank', description: 'The ultimate core stability exercise. Engages abs, back, shoulders, and glutes.', durationSeconds: 40, imageUrl: 'assets/exercises/plank.png', muscleGroup: 'core', instructions: ['Start on forearms and toes', 'Body forms a straight line from head to heels', 'Engage core by pulling belly button toward spine', 'Squeeze glutes, breathe steadily', 'Hold without sagging or piking']),
    Exercise(id: 'side_plank', name: 'Side Plank', description: 'Isometric exercise targeting the obliques and improving lateral stability.', durationSeconds: 35, imageUrl: 'assets/exercises/side_plank.png', muscleGroup: 'core', instructions: ['Lie on side, stack feet, prop on forearm', 'Lift hips until body forms a straight line', 'Hold, then lower with control', 'Repeat on other side']),
    Exercise(id: 'mountain_climbers', name: 'Mountain Climbers', description: 'Dynamic core exercise that combines cardio with core strengthening.', durationSeconds: 35, imageUrl: 'assets/exercises/mountain_climbers.png', muscleGroup: 'core', instructions: ['Start in high plank position', 'Drive right knee toward chest', 'Quickly switch legs, driving left knee in', 'Keep hips low, maintain plank form', 'Move as fast as you can maintain form']),
    Exercise(id: 'bicycle_crunches', name: 'Bicycle Crunches', description: 'Targets both the rectus abdominis and obliques through rotational movement.', durationSeconds: 35, imageUrl: 'assets/exercises/bicycle_crunches.png', muscleGroup: 'core', instructions: ['Lie on back, hands behind head', 'Bring right elbow to left knee while extending right leg', 'Switch sides smoothly', 'Keep core engaged throughout']),
    Exercise(id: 'dead_bug', name: 'Dead Bug', description: 'Core stability exercise that challenges coordination while protecting the lower back.', durationSeconds: 35, imageUrl: 'assets/exercises/dead_bug.png', muscleGroup: 'core', instructions: ['Lie on back, arms extended up, knees at 90°', 'Simultaneously lower right arm and left leg toward ground', 'Return to start, switch sides', 'Keep lower back pressed into the ground']),
    Exercise(id: 'russian_twists', name: 'Russian Twists', description: 'Rotational core exercise that targets obliques and improves rotational power.', durationSeconds: 35, imageUrl: '', muscleGroup: 'core', instructions: ['Sit with knees bent, feet hovering off ground', 'Lean back slightly, engage core', 'Twist torso to the right, then left', 'Touch ground beside you on each side']),
    Exercise(id: 'v_ups', name: 'V-Ups', description: 'Advanced core exercise that targets upper and lower abs simultaneously.', durationSeconds: 30, imageUrl: '', muscleGroup: 'core', instructions: ['Lie flat with arms extended overhead', 'Simultaneously lift legs and torso to form a V', 'Touch toes at the top', 'Lower slowly with control']),
    Exercise(id: 'leg_raises', name: 'Leg Raises', description: 'Isolation exercise for the lower abdominals with emphasis on control.', durationSeconds: 35, imageUrl: '', muscleGroup: 'core', instructions: ['Lie flat, legs extended, hands under hips', 'Lift legs to 90° keeping them straight', 'Lower slowly without arching lower back', 'Pause at bottom before next rep']),

    // ═══ GLUTES (4) ═══
    Exercise(id: 'single_glute_bridge', name: 'Single-Leg Glute Bridge', description: 'Unilateral glute exercise that corrects muscle imbalances.', durationSeconds: 35, imageUrl: '', muscleGroup: 'legs', instructions: ['Lie back, one knee bent, other leg extended', 'Drive through the working heel to lift hips', 'Squeeze glute at the top', 'Lower with control, repeat, switch legs']),
    Exercise(id: 'donkey_kicks', name: 'Donkey Kicks', description: 'Isolates the glutes with a focus on the upper glute fibers.', durationSeconds: 35, imageUrl: '', muscleGroup: 'legs', instructions: ['Start on hands and knees', 'Kick right leg up toward ceiling, knee bent at 90°', 'Keep foot flexed, squeeze glute at top', 'Don\'t arch the lower back']),
    Exercise(id: 'fire_hydrants', name: 'Fire Hydrants', description: 'Targets the gluteus medius for hip stability and rounded glute shape.', durationSeconds: 35, imageUrl: '', muscleGroup: 'legs', instructions: ['Start on hands and knees', 'Lift right leg out to the side, keeping knee bent', 'Keep hips level, don\'t rotate', 'Lower and repeat, switch sides']),
    Exercise(id: 'curtsey_lunges', name: 'Curtsey Lunges', description: 'Unique lunge variation that targets glute medius and inner thighs.', durationSeconds: 40, imageUrl: '', muscleGroup: 'legs', instructions: ['Step right leg behind and across left leg', 'Bend both knees, lowering into a curtsey', 'Keep torso upright', 'Push through right foot to return']),

    // ═══ CARDIO / HIIT (6) ═══
    Exercise(id: 'burpees', name: 'Burpees', description: 'The ultimate full-body exercise. Combines a squat, push-up, and jump in one fluid movement.', durationSeconds: 45, imageUrl: 'assets/exercises/burpees.png', muscleGroup: 'full_body', instructions: ['Squat down and place hands on ground', 'Jump feet back into plank position', 'Perform a push-up', 'Jump feet forward to squat position', 'Explosively jump up with arms overhead']),
    Exercise(id: 'box_jumps', name: 'Box Jumps', description: 'Explosive plyometric exercise for power development in the legs.', durationSeconds: 35, imageUrl: 'assets/exercises/box_jumps.png', muscleGroup: 'legs', instructions: ['Stand facing a sturdy box/platform', 'Squat slightly, swing arms back', 'Jump explosively onto the box', 'Land softly with bent knees', 'Step down, don\'t jump down']),
    Exercise(id: 'skater_jumps', name: 'Skater Jumps', description: 'Lateral plyometric exercise that improves agility and leg power.', durationSeconds: 35, imageUrl: '', muscleGroup: 'legs', instructions: ['Stand on right leg, left leg lifted', 'Leap laterally to the left', 'Land on left leg, touch ground with right hand', 'Immediately leap back to the right']),
    Exercise(id: 'mountain_climbers_slow', name: 'Slow Mountain Climbers', description: 'Controlled version of mountain climbers emphasizing core engagement.', durationSeconds: 40, imageUrl: '', muscleGroup: 'core', instructions: ['Start in plank position', 'Slowly drive right knee toward chest', 'Return to plank, repeat with left leg', 'Keep core tight, move deliberately']),
    Exercise(id: 'star_jumps', name: 'Star Jumps', description: 'Advanced plyometric move that engages the entire body.', durationSeconds: 30, imageUrl: '', muscleGroup: 'full_body', instructions: ['Squat down with arms at sides', 'Jump explosively, spreading arms and legs wide like a star', 'Land softly, immediately into next squat']),
    Exercise(id: 'plank_jacks', name: 'Plank Jacks', description: 'Plank variation that adds a cardio element to core work.', durationSeconds: 30, imageUrl: '', muscleGroup: 'core', instructions: ['Start in plank position', 'Jump both feet apart, then together', 'Keep upper body stable, hips level', 'Move feet quickly while maintaining plank form']),

    // ═══ ARMS (5) ═══
    Exercise(id: 'tricep_dips', name: 'Tricep Dips', description: 'The best bodyweight exercise for triceps development.', durationSeconds: 40, imageUrl: 'assets/exercises/tricep_dips.png', muscleGroup: 'arms', instructions: ['Place hands on edge of a chair/bench behind you', 'Lower your body by bending elbows to 90°', 'Push back up to starting position', 'Keep elbows pointing straight back']),
    Exercise(id: 'dips_advanced', name: 'Parallel Bar Dips', description: 'Advanced compound pushing movement for chest and triceps.', durationSeconds: 40, imageUrl: '', muscleGroup: 'arms', instructions: ['Support body on parallel bars or sturdy chairs', 'Lower body by bending elbows', 'Lean forward slightly to engage chest', 'Push back up to full arm extension']),
    Exercise(id: 'plank_up_downs', name: 'Plank Up-Downs', description: 'Builds shoulder stability and arm endurance.', durationSeconds: 35, imageUrl: '', muscleGroup: 'arms', instructions: ['Start in plank on forearms', 'Press up to high plank on right hand, then left', 'Lower back down to forearms, right then left', 'Alternate which arm leads']),
    Exercise(id: 'bear_crawl', name: 'Bear Crawl', description: 'Dynamic full-body exercise that challenges shoulders, core, and coordination.', durationSeconds: 35, imageUrl: '', muscleGroup: 'full_body', instructions: ['Start on hands and knees, knees hovering off ground', 'Move right hand and left foot forward simultaneously', 'Alternate with left hand and right foot', 'Keep back flat, crawl forward and backward']),
    Exercise(id: 'inchworm', name: 'Inchworm', description: 'Full-body mobility exercise that stretches hamstrings and builds shoulder endurance.', durationSeconds: 35, imageUrl: '', muscleGroup: 'full_body', instructions: ['Bend at waist, walk hands forward to plank', 'Take small steps with feet toward hands', 'Keep legs as straight as comfortable', 'Walk hands back out and repeat']),

    // ═══ YOGA / FLEXIBILITY (6) ═══
    Exercise(id: 'downward_dog', name: 'Downward Dog', description: 'Foundational yoga pose that stretches and strengthens the entire body.', durationSeconds: 40, imageUrl: '', muscleGroup: 'full_body', instructions: ['Start on hands and knees', 'Push hips up and back', 'Straighten arms and legs as much as comfortable', 'Press heels toward ground', 'Hold and breathe deeply']),
    Exercise(id: 'childs_pose', name: 'Child\'s Pose', description: 'Restorative pose that gently stretches the back, hips, and shoulders.', durationSeconds: 40, imageUrl: '', muscleGroup: 'back', instructions: ['Kneel on the mat, big toes touching', 'Sit back on heels', 'Fold forward, extending arms on the mat', 'Rest forehead on mat, breathe deeply']),
    Exercise(id: 'cat_cow', name: 'Cat-Cow Stretch', description: 'Spinal mobility exercise that warms up the entire back.', durationSeconds: 30, imageUrl: '', muscleGroup: 'back', instructions: ['Start on hands and knees', 'Inhale: drop belly, lift chest and tailbone (Cow)', 'Exhale: round spine, tuck chin to chest (Cat)', 'Flow between the two positions with breath']),
    Exercise(id: 'warrior_1', name: 'Warrior I', description: 'Powerful standing yoga pose that builds strength and stability.', durationSeconds: 40, imageUrl: '', muscleGroup: 'legs', instructions: ['Step one foot forward into a lunge', 'Square hips forward', 'Raise arms overhead, palms together', 'Hold, breathing deeply, then switch sides']),
    Exercise(id: 'warrior_2', name: 'Warrior II', description: 'Foundational yoga pose that strengthens legs and opens hips.', durationSeconds: 40, imageUrl: '', muscleGroup: 'legs', instructions: ['Wide stance, front knee bent at 90°', 'Extend arms out to sides parallel to ground', 'Gaze over front hand', 'Keep back leg straight and strong']),
    Exercise(id: 'tree_pose', name: 'Tree Pose', description: 'Balance pose that strengthens the ankles and core while improving focus.', durationSeconds: 35, imageUrl: '', muscleGroup: 'legs', instructions: ['Stand on one leg, place other foot on inner thigh or calf', 'Bring hands to prayer position at chest', 'Focus on a fixed point for balance', 'Hold, then switch sides']),
  ];

  static List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return _exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  static List<Exercise> getExercisesByDifficulty(int durationMinutes, String fitnessLevel) {
    int exerciseCount = durationMinutes * 60 ~/ 45;
    if (fitnessLevel == 'beginner') {
      exerciseCount = (exerciseCount * 0.7).toInt();
    } else if (fitnessLevel == 'advanced') {
      exerciseCount = (exerciseCount * 1.3).toInt();
    }
    return _exercises.take(exerciseCount.clamp(3, 18)).toList();
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
      description: _getDescription(goal, fitnessLevel, exercises.length, availableMinutes),
      durationMinutes: availableMinutes,
      difficulty: difficulty,
      exercises: exercises,
      createdAt: DateTime.now(),
    );
  }

  static List<Exercise> _selectExercises(String goal, String fitnessLevel, int minutes) {
    List<Exercise> selected = [];

    if (goal == 'loseWeight') {
      selected = _exercises.where((e) =>
        e.muscleGroup == 'full_body' || e.muscleGroup == 'core' || e.muscleGroup == 'legs'
      ).toList();
    } else if (goal == 'buildMuscle') {
      selected = _exercises.where((e) =>
        e.muscleGroup == 'chest' || e.muscleGroup == 'arms' || e.muscleGroup == 'back' || e.muscleGroup == 'legs'
      ).toList();
    } else {
      selected = List.from(_exercises);
    }

    int count = (minutes * 60 ~/ 45).clamp(4, 16).toInt();
    if (fitnessLevel == 'beginner') {
      count = (count * 0.7).toInt().clamp(3, 12);
    } else if (fitnessLevel == 'advanced') {
      count = (count * 1.2).toInt().clamp(5, 18);
    }

    selected.shuffle(_random);
    final result = selected.take(count).toList();
    // Always put a warm-up first if available
    final warmup = _exercises.where((e) => e.id == 'jumping_jacks' || e.id == 'arm_circles').toList()..shuffle(_random);
    if (warmup.isNotEmpty && result.isNotEmpty && result.first.id != warmup.first.id) {
      result.insert(0, warmup.first);
      if (result.length > count) result.removeLast();
    }
    return result;
  }

  static String _generateTitle(String goal, String fitnessLevel) {
    final titles = {
      'loseWeight': {
        'beginner': 'Light Cardio Blast',
        'intermediate': 'Fat Burn Circuit',
        'advanced': 'HIIT Inferno',
      },
      'buildMuscle': {
        'beginner': 'Foundation Builder',
        'intermediate': 'Muscle Sculptor',
        'advanced': 'Strength Dominance',
      },
      'stayActive': {
        'beginner': 'Gentle Movement Flow',
        'intermediate': 'Active Energy Boost',
        'advanced': 'Full Body Dominance',
      },
    };
    return titles[goal]?[fitnessLevel] ?? 'Daily Workout';
  }

  static String _getDifficulty(String fitnessLevel) {
    switch (fitnessLevel) {
      case 'beginner': return 'Easy';
      case 'intermediate': return 'Medium';
      case 'advanced': return 'Hard';
      default: return 'Medium';
    }
  }

  static String _getDescription(String goal, String fitnessLevel, int exerciseCount, int minutes) {
    final base = switch (goal) {
      'loseWeight' => 'High-intensity workout designed to maximize calorie burn and improve cardiovascular fitness.',
      'buildMuscle' => 'Strength-focused workout to build muscle and increase overall body strength.',
      'stayActive' => 'Balanced workout to keep you active and maintain your fitness level.',
      _ => 'A personalized workout based on your goals and fitness level.',
    };
    return '$base Includes $exerciseCount exercises over $minutes minutes at a $fitnessLevel pace.';
  }

  static Workout generateQuickWorkout(int minutes) {
    final exerciseCount = (minutes * 60 ~/ 45).clamp(3, 10);
    final exercises = _exercises.take(exerciseCount).toList()..shuffle(_random);
    return Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$minutes-Minute Quick Workout',
      description: 'A fast, efficient workout you can do anywhere. $exerciseCount exercises at a steady pace.',
      durationMinutes: minutes,
      difficulty: 'Medium',
      exercises: exercises,
      createdAt: DateTime.now(),
    );
  }

  static int get totalExerciseCount => _exercises.length;
  static List<String> get muscleGroups => _exercises.map((e) => e.muscleGroup).toSet().toList();
}
