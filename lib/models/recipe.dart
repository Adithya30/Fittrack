class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final Map<String, double> nutrition; // calories, protein, carbs, fats
  final String cuisineType; // 'kerala', 'south_indian', etc.
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final int servings;
  final String? imageUrl;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    required this.cuisineType,
    required this.mealType,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    this.imageUrl,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      nutrition: Map<String, double>.from(
        (json['nutrition'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      cuisineType: json['cuisine_type'] as String? ?? 'kerala',
      mealType: json['meal_type'] as String,
      prepTime: json['prep_time'] as int? ?? 0,
      cookTime: json['cook_time'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'nutrition': nutrition,
      'cuisine_type': cuisineType,
      'meal_type': mealType,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      if (imageUrl != null) 'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
