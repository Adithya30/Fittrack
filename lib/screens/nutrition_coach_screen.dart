import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../models/user_biometrics.dart';
import '../theme/anti_gravity_theme.dart';
import 'recipe_screen.dart';

class NutritionCoachScreen extends StatefulWidget {
  const NutritionCoachScreen({super.key});

  @override
  State<NutritionCoachScreen> createState() => _NutritionCoachScreenState();
}

class _NutritionCoachScreenState extends State<NutritionCoachScreen> {
  final _geminiService = GeminiService();
  final _databaseService = DatabaseService();
  final _authService = AuthService();

  UserBiometrics? _biometrics;
  bool _isLoadingBiometrics = true;
  bool _isGeneratingRecipe = false;
  bool _isLoadingAdvice = false;
  String? _nutritionAdvice;
  String _selectedMealType = 'breakfast';
  String _selectedCuisine = 'South Indian';
  bool _isVegetarian = false;
  final TextEditingController _customRequestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  @override
  void dispose() {
    _customRequestController.dispose();
    super.dispose();
  }

  // ... (Keeping your existing logic functions: _loadBiometrics, _generateRecipe, _getNutritionAdvice)
  // Logic remains unchanged to ensure your backend connectivity works.

  Future<void> _loadBiometrics() async {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() => _isLoadingBiometrics = false);
      return;
    }
    try {
      final biometrics = await _databaseService.getUserBiometrics(user.id);
      setState(() {
        _biometrics = biometrics;
        _isLoadingBiometrics = false;
      });
    } catch (e) {
      setState(() => _isLoadingBiometrics = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _generateRecipe() async {
    if (_biometrics == null) return;
    setState(() => _isGeneratingRecipe = true);
    try {
      final recipe = await _geminiService.generateRecipe(
        biometrics: _biometrics!,
        mealType: _selectedMealType,
        cuisineType: _selectedCuisine,
        isVegetarian: _isVegetarian,
        customRequest: _customRequestController.text.isNotEmpty ? _customRequestController.text : null,
      );
      final user = _authService.currentUser;
      if (user != null) await _databaseService.saveRecipe(recipe, user.id);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeScreen(recipe: recipe)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isGeneratingRecipe = false);
    }
  }

  Future<void> _getNutritionAdvice() async {
    if (_biometrics == null) return;
    setState(() {
      _isLoadingAdvice = true;
      _nutritionAdvice = null;
    });
    try {
      final advice = await _geminiService.getNutritionAdvice(biometrics: _biometrics!);
      setState(() => _nutritionAdvice = advice);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Advice Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingAdvice = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUTRITION COACH'),
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
          child: _isLoadingBiometrics
              ? const Center(child: CircularProgressIndicator())
              : _biometrics == null
                  ? _buildSetupPrompt()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMacroCard(),
                          const SizedBox(height: 24),
                          _buildMealSelectionCard(),
                          const SizedBox(height: 24),
                          _buildAdviceCard(),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  // HELPER: The Dynamic Glass Card (No fixed height)
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AntiGravityTheme.pureWhite.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AntiGravityTheme.pureWhite.withOpacity(0.2), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DAILY MACRO TARGETS', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2)),
          const SizedBox(height: 20),
          _buildMacroItem('CALORIES', '${_biometrics!.dailyCalorieTarget.toStringAsFixed(0)} kcal', Icons.local_fire_department),
          const SizedBox(height: 16),
          _buildMacroItem('PROTEIN', '${_biometrics!.dailyProteinTarget.toStringAsFixed(0)} g', Icons.fitness_center),
          const SizedBox(height: 16),
          _buildMacroItem('CARBS', '${_biometrics!.dailyCarbsTarget.toStringAsFixed(0)} g', Icons.breakfast_dining),
        ],
      ),
    );
  }

  Widget _buildMealSelectionCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SELECT MEAL TYPE', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Prevents SegmentedButton overflow on small screens
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'breakfast', label: Text('BREAKFAST')),
                ButtonSegment(value: 'lunch', label: Text('LUNCH')),
                ButtonSegment(value: 'dinner', label: Text('DINNER')),
                ButtonSegment(value: 'snack', label: Text('SNACK')),
              ],
              selected: {_selectedMealType},
              onSelectionChanged: (newSelection) => setState(() => _selectedMealType = newSelection.first),
            ),
          ),
          const SizedBox(height: 20),
          Text('CUISINE STYLE', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'South Indian', label: Text('SOUTH INDIAN')),
                ButtonSegment(value: 'North Indian', label: Text('NORTH INDIAN')),
              ],
              selected: {_selectedCuisine},
              onSelectionChanged: (newSelection) => setState(() => _selectedCuisine = newSelection.first),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('VEGETARIAN ONLY', style: Theme.of(context).textTheme.bodyLarge),
            value: _isVegetarian,
            onChanged: (bool value) => setState(() => _isVegetarian = value),
            activeColor: AntiGravityTheme.pureWhite,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customRequestController,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Custom Request (e.g., "Paneer", "Spicy", "No Oil")',
              labelStyle: TextStyle(color: AntiGravityTheme.pureWhite.withOpacity(0.7)),
              filled: true,
              fillColor: AntiGravityTheme.pureWhite.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AntiGravityTheme.pureWhite.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AntiGravityTheme.pureWhite.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AntiGravityTheme.pureWhite),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isGeneratingRecipe ? null : _generateRecipe,
            icon: _isGeneratingRecipe ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.restaurant_menu),
            label: Text(_isGeneratingRecipe ? 'GENERATING...' : 'GENERATE RECIPE'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NUTRITION ADVICE', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2)),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _isLoadingAdvice ? null : _getNutritionAdvice,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingAdvice)
            const Center(child: CircularProgressIndicator())
          else if (_nutritionAdvice != null)
            Text(_nutritionAdvice!, style: Theme.of(context).textTheme.bodyMedium)
          else
            Center(
              child: ElevatedButton.icon(
                onPressed: _getNutritionAdvice,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('GET PERSONALIZED ADVICE'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetupPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: AntiGravityTheme.pureWhite),
          const SizedBox(height: 16),
          Text('SET UP YOUR BIOMETRICS FIRST', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AntiGravityTheme.pureWhite, size: 24),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(letterSpacing: 1.5))),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}