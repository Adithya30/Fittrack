import '../config/supabase_config.dart';
import '../models/user_biometrics.dart';
import '../models/recipe.dart';
import '../models/food_log.dart';

class DatabaseService {
  final _supabase = SupabaseConfig.client;

  // User Biometrics Operations
  Future<UserBiometrics?> getUserBiometrics(String userId) async {
    try {
      final response = await _supabase
          .from('user_biometrics')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserBiometrics.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch user biometrics: $e');
    }
  }

  Future<UserBiometrics> saveUserBiometrics(UserBiometrics biometrics) async {
    try {
      final existing = await getUserBiometrics(biometrics.userId);
      
      if (existing != null) {
        // Update existing
        final response = await _supabase
            .from('user_biometrics')
            .update(biometrics.copyWith(updatedAt: DateTime.now()).toJson())
            .eq('user_id', biometrics.userId)
            .select()
            .single();
        
        return UserBiometrics.fromJson(response as Map<String, dynamic>);
      } else {
        // Insert new
        final response = await _supabase
            .from('user_biometrics')
            .insert(biometrics.copyWith(createdAt: DateTime.now()).toJson())
            .select()
            .single();
        
        return UserBiometrics.fromJson(response as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Failed to save user biometrics: $e');
    }
  }

  // Recipe Operations
  Future<List<Recipe>> getUserRecipes(String userId) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recipes: $e');
    }
  }

  Future<Recipe> saveRecipe(Recipe recipe, String userId) async {
    try {
      final recipeJson = recipe.toJson();
      recipeJson['user_id'] = userId;
      
      final response = await _supabase
          .from('recipes')
          .insert(recipeJson)
          .select()
          .single();
      
      return Recipe.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to save recipe: $e');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _supabase.from('recipes').delete().eq('id', recipeId);
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  // Food Log Operations
  Future<List<FoodLog>> getFoodLogs(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('food_logs')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => FoodLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist yet or error occurs
      return [];
    }
  }

  Future<FoodLog> saveFoodLog(FoodLog log) async {
    try {
      final response = await _supabase
          .from('food_logs')
          .insert(log.toJson())
          .select()
          .single();
      
      return FoodLog.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to save food log: $e');
    }
  }

  Future<void> deleteFoodLog(String logId) async {
    try {
      await _supabase.from('food_logs').delete().eq('id', logId);
    } catch (e) {
      throw Exception('Failed to delete food log: $e');
    }
  }
}
