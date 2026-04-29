class FoodLog {
  final String id;
  final String userId;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime date;
  final DateTime createdAt;

  FoodLog({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
    required this.createdAt,
  });

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      foodName: json['food_name'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_name': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'date': date.toIso8601String().split('T')[0], // Store as YYYY-MM-DD for querying
      'created_at': createdAt.toIso8601String(),
    };
  }
}