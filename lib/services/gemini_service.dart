import 'dart:convert';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';
import '../models/user_biometrics.dart';
import '../models/recipe.dart';
import '../models/workout_plan.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
    );
    print('DEBUG: Initialized Gemini with model: ${GeminiConfig.model}');
  }

  /// Generate personalized Kerala cuisine recipe based on user biometrics
  Future<Recipe> generateRecipe({
    required UserBiometrics biometrics,
    required String mealType,
    required String cuisineType,
    required bool isVegetarian,
    String? customRequest,
    List<String>? availableIngredients,
    String? dietaryPreferences,
  }) async {
    try {
      // Generate a random focus to ensure variety on each refresh
      final random = Random();
      final varietyOptions = [
        'Focus on a high-protein preparation',
        'Highlight seasonal vegetables',
        'Use a quick and easy cooking method',
        'Incorporate traditional spices for immunity',
        'Create a homestyle comfort dish',
        'Suggest a low-oil healthy variation',
        'Focus on a fiber-rich meal',
        'Try a unique regional specialty',
      ];
      final varietyFocus = varietyOptions[random.nextInt(varietyOptions.length)];

      final prompt = _buildRecipePrompt(
        biometrics: biometrics,
        mealType: mealType,
        cuisineType: cuisineType,
        isVegetarian: isVegetarian,
        customRequest: customRequest,
        varietyFocus: varietyFocus,
        availableIngredients: availableIngredients,
        dietaryPreferences: dietaryPreferences,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      return _parseRecipeResponse(text, mealType, cuisineType);
    } catch (e) {
      throw Exception('Failed to generate recipe: $e');
    }
  }

  /// Generate a weekly workout plan
  Future<WorkoutPlan> generateWorkoutPlan({
    required UserBiometrics biometrics,
  }) async {
    try {
      final random = Random();
      final styles = [
        'Hypertrophy (Muscle Growth) focus',
        'Strength & Power focus',
        'Endurance & Conditioning focus',
        'Push-Pull-Legs Split',
        'Upper-Lower Body Split',
        'Full Body High Frequency',
        'Functional Fitness & Mobility',
      ];
      final styleFocus = styles[random.nextInt(styles.length)];

      final prompt = '''
You are an expert fitness coach. Generate a 7-day weekly workout split for this user:
PROFILE: ${biometrics.gender}, ${biometrics.age} years, ${biometrics.weight}kg, Goal: ${biometrics.goal}.
FOCUS FOR THIS WEEK: $styleFocus.

Return a JSON object with this structure:
{
  "title": "Name of the split (e.g., 'High Volume Push-Pull')",
  "description": "Brief strategy description",
  "schedule": [
    { "day": "Monday", "focus": "Chest & Triceps", "exercises": [{ "name": "Bench Press", "sets": "3", "reps": "8-12" }] },
    ... (for all 7 days, use "Rest" for rest days)
  ]
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseWorkoutResponse(response.text ?? '');
    } catch (e) {
      throw Exception('Failed to generate workout plan: $e');
    }
  }

  /// Get nutrition advice based on biometrics
  Future<String> getNutritionAdvice({
    required UserBiometrics biometrics,
    String? specificQuestion,
  }) async {
    try {
      final prompt = _buildNutritionAdvicePrompt(
        biometrics: biometrics,
        specificQuestion: specificQuestion,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate advice at this time.';
    } catch (e) {
      throw Exception('Failed to get nutrition advice: $e');
    }
  }

  /// Estimate nutrition for a food item based on name and quantity
  Future<Map<String, double>> estimateNutrition({
    required String foodName,
    required String quantity,
  }) async {
    try {
      final prompt = '''
You are an expert nutritionist. Estimate the macronutrients for:
Food: $foodName
Quantity: $quantity

Return a JSON object with this structure (values as numbers):
{
  "calories": number,
  "protein": number (grams),
  "carbs": number (grams),
  "fats": number (grams)
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      // Reuse parsing logic or create simple one
      String jsonString = text.trim();
      if (jsonString.startsWith('```json')) jsonString = jsonString.substring(7);
      if (jsonString.startsWith('```')) jsonString = jsonString.substring(3);
      if (jsonString.endsWith('```')) jsonString = jsonString.substring(0, jsonString.length - 3);
      jsonString = jsonString.trim();

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return {
        'calories': (json['calories'] as num).toDouble(),
        'protein': (json['protein'] as num).toDouble(),
        'carbs': (json['carbs'] as num).toDouble(),
        'fats': (json['fats'] as num).toDouble(),
      };
    } catch (e) {
      print('Error estimating nutrition: $e');
      return {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fats': 0,
      };
    }
  }

  /// Build recipe generation prompt
  String _buildRecipePrompt({
    required UserBiometrics biometrics,
    required String mealType,
    required String cuisineType,
    required bool isVegetarian,
    required String? customRequest,
    required String varietyFocus,
    List<String>? availableIngredients,
    String? dietaryPreferences,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are an expert nutritionist specializing in healthy Indian cuisine.');
    buffer.writeln('\nGenerate a personalized recipe with the following specifications:');
    buffer.writeln('\nUSER PROFILE:');
    buffer.writeln('- Height: ${biometrics.height} cm');
    buffer.writeln('- Weight: ${biometrics.weight} kg');
    buffer.writeln('- Age: ${biometrics.age} years');
    buffer.writeln('- Gender: ${biometrics.gender}');
    buffer.writeln('- Goal: ${biometrics.goal}');
    buffer.writeln('- Daily Calorie Target: ${biometrics.dailyCalorieTarget.toStringAsFixed(0)} kcal');
    buffer.writeln('- Daily Protein Target: ${biometrics.dailyProteinTarget.toStringAsFixed(0)} g');
    buffer.writeln('- Daily Carbs Target: ${biometrics.dailyCarbsTarget.toStringAsFixed(0)} g');
    buffer.writeln('- Activity Level: ${biometrics.activityLevel}');
    buffer.writeln('\nMEAL REQUIREMENTS:');
    buffer.writeln('- Meal Type: $mealType');
    buffer.writeln('- Cuisine Style: $cuisineType (Authentic regional style)');
    buffer.writeln('- Diet Type: ${isVegetarian ? "Vegetarian (Strictly Veg)" : "Non-Vegetarian (Chicken/Fish/Meat allowed)"}');
    buffer.writeln('- Variation Focus: $varietyFocus');
    
    if (customRequest != null && customRequest.isNotEmpty) {
      buffer.writeln('- User Custom Request: $customRequest');
    }
    
    if (availableIngredients != null && availableIngredients.isNotEmpty) {
      buffer.writeln('\nAVAILABLE INGREDIENTS:');
      buffer.writeln(availableIngredients.join(', '));
    }
    
    if (dietaryPreferences != null && dietaryPreferences.isNotEmpty) {
      buffer.writeln('\nDIETARY PREFERENCES: $dietaryPreferences');
    }
    
    buffer.writeln('\nREQUIREMENTS:');
    buffer.writeln('1. Recipe must be healthy and align with the user\'s fitness goals');
    buffer.writeln('2. Use traditional ingredients and cooking methods suitable for $cuisineType');
    buffer.writeln('3. Provide exact ingredient quantities');
    buffer.writeln('4. Include detailed step-by-step cooking instructions');
    buffer.writeln('5. Calculate and provide nutritional information per serving');
    buffer.writeln('6. Ensure the recipe fits within the daily macro targets');
    
    buffer.writeln('\nRESPONSE FORMAT (JSON only, no markdown):');
    buffer.writeln('{');
    buffer.writeln('  "title": "Recipe name",');
    buffer.writeln('  "description": "Brief description",');
    buffer.writeln('  "ingredients": ["ingredient 1 with quantity", "ingredient 2 with quantity", ...],');
    buffer.writeln('  "instructions": ["step 1", "step 2", ...],');
    buffer.writeln('  "nutrition": {');
    buffer.writeln('    "calories": number,');
    buffer.writeln('    "protein": number (in grams),');
    buffer.writeln('    "carbs": number (in grams),');
    buffer.writeln('    "fats": number (in grams)');
    buffer.writeln('  },');
    buffer.writeln('  "prep_time": number (minutes),');
    buffer.writeln('  "cook_time": number (minutes),');
    buffer.writeln('  "servings": number');
    buffer.writeln('}');
    
    return buffer.toString();
  }

  /// Build nutrition advice prompt
  String _buildNutritionAdvicePrompt({
    required UserBiometrics biometrics,
    String? specificQuestion,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are a professional nutritionist and fitness coach specializing in Kerala cuisine.');
    buffer.writeln('\nUSER PROFILE:');
    buffer.writeln('- Height: ${biometrics.height} cm');
    buffer.writeln('- Weight: ${biometrics.weight} kg');
    buffer.writeln('- BMI: ${biometrics.bmi.toStringAsFixed(1)}');
    buffer.writeln('- Age: ${biometrics.age} years');
    buffer.writeln('- Gender: ${biometrics.gender}');
    buffer.writeln('- Goal: ${biometrics.goal}');
    buffer.writeln('- BMR: ${biometrics.bmr.toStringAsFixed(0)} kcal');
    buffer.writeln('- TDEE: ${biometrics.tdee.toStringAsFixed(0)} kcal');
    buffer.writeln('- Daily Calorie Target: ${biometrics.dailyCalorieTarget.toStringAsFixed(0)} kcal');
    buffer.writeln('- Daily Protein: ${biometrics.dailyProteinTarget.toStringAsFixed(0)} g');
    buffer.writeln('- Daily Carbs: ${biometrics.dailyCarbsTarget.toStringAsFixed(0)} g');
    buffer.writeln('- Activity Level: ${biometrics.activityLevel}');
    
    if (specificQuestion != null && specificQuestion.isNotEmpty) {
      buffer.writeln('\nSPECIFIC QUESTION: $specificQuestion');
    } else {
      buffer.writeln('\nProvide personalized nutrition advice including:');
      buffer.writeln('1. Meal timing recommendations');
      buffer.writeln('2. Macro distribution throughout the day');
      buffer.writeln('3. Best Kerala foods for their goals');
      buffer.writeln('4. Hydration and supplement suggestions');
      buffer.writeln('5. Tips for meal prep and consistency');
    }
    
    buffer.writeln('\nKeep the advice practical, culturally relevant to Kerala cuisine, and actionable.');
    
    return buffer.toString();
  }

  /// Parse recipe response from Gemini
  Recipe _parseRecipeResponse(String response, String mealType, String cuisineType) {
    try {
      // Extract JSON from response (handle markdown code blocks)
      String jsonString = response.trim();
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        ingredients: List<String>.from(json['ingredients'] as List),
        instructions: List<String>.from(json['instructions'] as List),
        nutrition: Map<String, double>.from(
          (json['nutrition'] as Map).map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          ),
        ),
        cuisineType: json['cuisine_type'] as String? ?? cuisineType,
        mealType: mealType,
        prepTime: json['prep_time'] as int? ?? 0,
        cookTime: json['cook_time'] as int? ?? 0,
        servings: json['servings'] as int? ?? 1,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // Fallback recipe if parsing fails
      return Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Healthy $cuisineType Meal',
        description: 'A nutritious meal tailored to your goals.',
        ingredients: ['Rice', 'Vegetables', 'Spices', 'Coconut'],
        instructions: ['Prepare ingredients', 'Cook according to traditional methods'],
        nutrition: {
          'calories': 400,
          'protein': 20,
          'carbs': 50,
          'fats': 10,
        },
        cuisineType: cuisineType,
        mealType: mealType,
        prepTime: 15,
        cookTime: 30,
        servings: 1,
        createdAt: DateTime.now(),
      );
    }
  }

  WorkoutPlan _parseWorkoutResponse(String response) {
    try {
      String jsonString = response.trim();
      if (jsonString.startsWith('```json')) jsonString = jsonString.substring(7);
      if (jsonString.startsWith('```')) jsonString = jsonString.substring(3);
      if (jsonString.endsWith('```')) jsonString = jsonString.substring(0, jsonString.length - 3);
      
      return WorkoutPlan.fromJson(jsonDecode(jsonString.trim()));
    } catch (e) {
      return WorkoutPlan(
        id: 'error', 
        title: 'Standard Split', 
        description: 'Fallback plan due to generation error.', 
        schedule: [], 
        createdAt: DateTime.now());
    }
  }
}
