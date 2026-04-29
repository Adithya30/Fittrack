class WorkoutPlan {
  final String id;
  final String title;
  final String description;
  final List<WorkoutDay> schedule;
  final DateTime createdAt;

  WorkoutPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.schedule,
    required this.createdAt,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Weekly Plan',
      description: json['description'] ?? '',
      schedule: (json['schedule'] as List)
          .map((item) => WorkoutDay.fromJson(item))
          .toList(),
      createdAt: DateTime.now(),
    );
  }
}

class WorkoutDay {
  final String day;
  final String focus;
  final List<Exercise> exercises;

  WorkoutDay({
    required this.day,
    required this.focus,
    required this.exercises,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      day: json['day'] ?? '',
      focus: json['focus'] ?? 'Rest',
      exercises: (json['exercises'] as List? ?? [])
          .map((item) => Exercise.fromJson(item))
          .toList(),
    );
  }
}

class Exercise {
  final String name;
  final String sets;
  final String reps;
  bool isCompleted;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      sets: json['sets'] ?? '0',
      reps: json['reps'] ?? '0',
    );
  }
}