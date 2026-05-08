class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? goal;
  final String? fitnessLevel;
  final int? availableMinutes;
  final DateTime? createdAt;
  final bool isOnboarded;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.goal,
    this.fitnessLevel,
    this.availableMinutes,
    this.createdAt,
    this.isOnboarded = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? goal,
    String? fitnessLevel,
    int? availableMinutes,
    DateTime? createdAt,
    bool? isOnboarded,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    goal: goal ?? this.goal,
    fitnessLevel: fitnessLevel ?? this.fitnessLevel,
    availableMinutes: availableMinutes ?? this.availableMinutes,
    createdAt: createdAt ?? this.createdAt,
    isOnboarded: isOnboarded ?? this.isOnboarded,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'goal': goal,
    'fitnessLevel': fitnessLevel,
    'availableMinutes': availableMinutes,
    'createdAt': createdAt?.toIso8601String(),
    'isOnboarded': isOnboarded,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    goal: json['goal'] as String?,
    fitnessLevel: json['fitnessLevel'] as String?,
    availableMinutes: json['availableMinutes'] as int?,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    isOnboarded: json['isOnboarded'] as bool? ?? false,
  );
}

enum UserGoal {
  loseWeight,
  buildMuscle,
  stayActive,
}

enum FitnessLevel {
  beginner,
  intermediate,
  advanced,
}