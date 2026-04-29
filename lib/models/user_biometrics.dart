class UserBiometrics {
  final String? id;
  final String userId;
  final double height; // in cm
  final double weight; // in kg
  final double? targetWeight; // in kg
  final int age;
  final String gender; // 'male', 'female', 'other'
  final String goal; // 'bulk', 'cut', 'maintain', 'lean_bulk'
  final double? bodyFatPercentage;
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserBiometrics({
    this.id,
    required this.userId,
    required this.height,
    required this.weight,
    this.targetWeight,
    required this.age,
    required this.gender,
    required this.goal,
    this.bodyFatPercentage,
    required this.activityLevel,
    this.createdAt,
    this.updatedAt,
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  double get bmr {
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }
    return bmr;
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double get tdee {
    final activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (activityMultipliers[activityLevel.toLowerCase()] ?? 1.2);
  }

  // Calculate daily calorie target based on goal
  double get dailyCalorieTarget {
    switch (goal.toLowerCase()) {
      case 'bulk':
        return tdee + 500; // Surplus for muscle gain
      case 'cut':
        return tdee - 500; // Deficit for fat loss
      case 'lean_bulk':
        return tdee + 250; // Moderate surplus
      case 'maintain':
      default:
        return tdee;
    }
  }

  // Calculate protein target (g)
  double get dailyProteinTarget {
    return weight * 2.2; // 1g per lb of bodyweight
  }

  // Calculate carbs target (g) - remaining calories after protein and fat
  double get dailyCarbsTarget {
    final proteinCalories = dailyProteinTarget * 4;
    final fatCalories = dailyCalorieTarget * 0.25; // 25% from fat
    final carbsCalories = dailyCalorieTarget - proteinCalories - fatCalories;
    return carbsCalories / 4;
  }

  // Calculate fat target (g) - 25% of daily calories
  double get dailyFatTarget {
    return (dailyCalorieTarget * 0.25) / 9;
  }

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'height': height,
      'weight': weight,
      if (targetWeight != null) 'target_weight': targetWeight,
      'age': age,
      'gender': gender,
      'goal': goal,
      if (bodyFatPercentage != null) 'body_fat_percentage': bodyFatPercentage,
      'activity_level': activityLevel,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserBiometrics.fromJson(Map<String, dynamic> json) {
    return UserBiometrics(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      targetWeight: json['target_weight'] != null
          ? (json['target_weight'] as num).toDouble()
          : null,
      age: json['age'] as int,
      gender: json['gender'] as String,
      goal: json['goal'] as String,
      bodyFatPercentage: json['body_fat_percentage'] != null
          ? (json['body_fat_percentage'] as num).toDouble()
          : null,
      activityLevel: json['activity_level'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Create copy with updated fields
  UserBiometrics copyWith({
    String? id,
    String? userId,
    double? height,
    double? weight,
    double? targetWeight,
    int? age,
    String? gender,
    String? goal,
    double? bodyFatPercentage,
    String? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserBiometrics(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
