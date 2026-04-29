import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/anti_gravity_theme.dart';

class RecipeScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECIPE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AntiGravityTheme.meshColors,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Recipe Header
                _buildDynamicGlassCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title.toUpperCase(),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildInfoChip(context, Icons.access_time, '${recipe.prepTime + recipe.cookTime} min'),
                          _buildInfoChip(context, Icons.people_outline, '${recipe.servings} serving${recipe.servings > 1 ? 's' : ''}'),
                          _buildInfoChip(context, Icons.restaurant, recipe.mealType.toUpperCase()),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Nutrition Info
                _buildDynamicGlassCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NUTRITION PER SERVING',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNutritionItem(context, 'CAL', recipe.nutrition['calories']?.toStringAsFixed(0) ?? '0'),
                          _buildNutritionItem(context, 'PROTEIN', '${recipe.nutrition['protein']?.toStringAsFixed(0) ?? '0'}g'),
                          _buildNutritionItem(context, 'CARBS', '${recipe.nutrition['carbs']?.toStringAsFixed(0) ?? '0'}g'),
                          _buildNutritionItem(context, 'FATS', '${recipe.nutrition['fats']?.toStringAsFixed(0) ?? '0'}g'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Ingredients
                _buildDynamicGlassCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INGREDIENTS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2),
                      ),
                      const SizedBox(height: 16),
                      ...recipe.ingredients.asMap().entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStepNumber(context, entry.key + 1, size: 24),
                                const SizedBox(width: 12),
                                Expanded(child: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Instructions
                _buildDynamicGlassCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INSTRUCTIONS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2),
                      ),
                      const SizedBox(height: 16),
                      ...recipe.instructions.asMap().entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStepNumber(context, entry.key + 1, size: 32, isInstruction: true),
                                const SizedBox(width: 12),
                                Expanded(child: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // REPLACEMENT: This helper uses standard widgets to allow dynamic height
  Widget _buildDynamicGlassCard(BuildContext context, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AntiGravityTheme.pureWhite.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AntiGravityTheme.pureWhite.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildStepNumber(BuildContext context, int number, {required double size, bool isInstruction = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isInstruction ? AntiGravityTheme.pureWhite.withOpacity(0.1) : Colors.transparent,
        shape: isInstruction ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isInstruction ? BorderRadius.circular(8) : null,
        border: Border.all(color: AntiGravityTheme.pureWhite.withOpacity(0.5), width: 1.5),
      ),
      child: Center(
        child: Text(
          '$number',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isInstruction ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AntiGravityTheme.pureWhite.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AntiGravityTheme.pureWhite.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AntiGravityTheme.pureWhite),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.5)),
      ],
    );
  }
}