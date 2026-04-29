import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';
import '../models/user_biometrics.dart';
import '../models/food_log.dart';
import '../theme/anti_gravity_theme.dart';

class FoodTrackerScreen extends StatefulWidget {
  const FoodTrackerScreen({super.key});

  @override
  State<FoodTrackerScreen> createState() => _FoodTrackerScreenState();
}

class _FoodTrackerScreenState extends State<FoodTrackerScreen> {
  final _databaseService = DatabaseService();
  final _geminiService = GeminiService();
  final _authService = AuthService();

  UserBiometrics? _biometrics;
  List<FoodLog> _todayLogs = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final biometrics = await _databaseService.getUserBiometrics(user.id);
      final logs = await _databaseService.getFoodLogs(user.id, _selectedDate);
      
      if (mounted) {
        setState(() {
          _biometrics = biometrics;
          _todayLogs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _addFoodLog(String name, double cal, double prot, double carb, double fat) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final newLog = FoodLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      foodName: name,
      calories: cal,
      protein: prot,
      carbs: carb,
      fats: fat,
      date: _selectedDate,
      createdAt: DateTime.now(),
    );

    try {
      await _databaseService.saveFoodLog(newLog);
      _loadData(); // Refresh
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  void _showAddFoodDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AntiGravityTheme.darkGray,
        title: const Text('Add Food', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Food Name'),
              const SizedBox(height: 10),
              _buildTextField(quantityController, 'Quantity (e.g., 1 cup, 100g)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || quantityController.text.isEmpty) return;
              
              Navigator.pop(context); // Close dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analyzing food nutrition...')),
              );

              try {
                final nutrition = await _geminiService.estimateNutrition(
                  foodName: nameController.text,
                  quantity: quantityController.text,
                );
                
                await _addFoodLog(
                  nameController.text,
                  nutrition['calories'] ?? 0,
                  nutrition['protein'] ?? 0,
                  nutrition['carbs'] ?? 0,
                  nutrition['fats'] ?? 0,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    double totalCal = 0, totalProt = 0, totalCarb = 0, totalFat = 0;
    for (var log in _todayLogs) {
      totalCal += log.calories;
      totalProt += log.protein;
      totalCarb += log.carbs;
      totalFat += log.fats;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('FOOD TRACKER')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: AntiGravityTheme.pureWhite,
        child: const Icon(Icons.add, color: Colors.black),
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_biometrics != null) ...[
                        _buildGoalCard(_biometrics!),
                        const SizedBox(height: 20),
                        _buildProgressCard(totalCal, totalProt, totalCarb, totalFat, _biometrics!),
                      ] else
                        const Center(child: Text('Please set up biometrics first.', style: TextStyle(color: Colors.white))),
                      const SizedBox(height: 24),
                      Text('TODAY\'S LOGS', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2)),
                      const SizedBox(height: 16),
                      _buildLogsList(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
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

  Widget _buildGoalCard(UserBiometrics bio) {
    return _buildGlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURRENT WEIGHT', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('${bio.weight} kg', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.arrow_forward, color: Colors.white54),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('TARGET WEIGHT', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    bio.targetWeight != null ? '${bio.targetWeight} kg' : '--',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'GOAL: ${bio.goal.toUpperCase()}',
            style: TextStyle(color: AntiGravityTheme.pureWhite, letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double cal, double prot, double carb, double fat, UserBiometrics bio) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBar('Calories', cal, bio.dailyCalorieTarget, 'kcal'),
          const SizedBox(height: 16),
          _buildProgressBar('Protein', prot, bio.dailyProteinTarget, 'g'),
          const SizedBox(height: 16),
          _buildProgressBar('Carbs', carb, bio.dailyCarbsTarget, 'g'),
          const SizedBox(height: 16),
          _buildProgressBar('Fats', fat, bio.dailyCalorieTarget * 0.25 / 9, 'g'), // Approx fat target
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double current, double target, String unit) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            Text('${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit', style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white10,
          color: progress > 1.0 ? Colors.redAccent : Colors.greenAccent,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLogsList() {
    if (_todayLogs.isEmpty) {
      return const Center(child: Text('No food logged today.', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todayLogs.length,
      itemBuilder: (context, index) {
        final log = _todayLogs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.foodName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('${log.calories.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Text('P:${log.protein.toStringAsFixed(0)} C:${log.carbs.toStringAsFixed(0)} F:${log.fats.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
  // lib/screens/food_tracker_screen.dart
// ... imports from your snippet ...

  Widget _buildGoalCard(UserBiometrics bio) {
    // Calculate weight remaining
    double difference = 0;
    if (bio.targetWeight != null) {
      difference = (bio.targetWeight! - bio.weight).abs();
    }

    return _buildGlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeightStat('CURRENT', '${bio.weight}', 'kg'),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  bio.goal == 'bulk' ? Icons.trending_up : Icons.trending_down,
                  color: Colors.greenAccent,
                  size: 20,
                ),
              ),
              _buildWeightStat('TARGET', '${bio.targetWeight ?? '--'}', 'kg'),
            ],
          ),
          const SizedBox(height: 15),
          // Weight Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: bio.weightProgress,
              minHeight: 6,
              backgroundColor: Colors.white10,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bio.targetWeight != null 
              ? '${difference.toStringAsFixed(1)}kg to go until ${bio.goal.toUpperCase()} goal' 
              : 'Set a target weight in profile',
            style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: label == 'TARGET' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(unit, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  // UPDATED: Macro Progress Card with a cleaner layout
  Widget _buildProgressCard(double cal, double prot, double carb, double fat, UserBiometrics bio) {
    return _buildGlassCard(
      child: Column(
        children: [
          // Large Calorie Ring or Linear Bar
          _buildProgressBar('Daily Calories', cal, bio.dailyCalorieTarget, 'kcal', Colors.blueAccent),
          const Divider(color: Colors.white10, height: 32),
          // Macros in a grid-like layout
          Row(
            children: [
              Expanded(child: _buildMacroMiniProgress('Protein', prot, bio.dailyProteinTarget, 'g', Colors.orangeAccent)),
              const SizedBox(width: 15),
              Expanded(child: _buildMacroMiniProgress('Carbs', carb, bio.dailyCarbsTarget, 'g', Colors.greenAccent)),
              const SizedBox(width: 15),
              Expanded(child: _buildMacroMiniProgress('Fats', fat, bio.dailyFatTarget, 'g', Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgress(UserBiometrics bio, double currentCalories) {
  return Column(
    children: [
      Text("Goal: ${bio.dailyCalorieTarget.toInt()} kcal"),
      LinearProgressIndicator(
        value: currentCalories / bio.dailyCalorieTarget,
        color: Colors.greenAccent,
      ),
      Text("BMR: ${bio.bmr.toInt()} | TDEE: ${bio.tdee.toInt()}"),
    ],
  );
}
}