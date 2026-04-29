import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/user_biometrics.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../theme/anti_gravity_theme.dart';

class BiometricsScreen extends StatefulWidget {
  const BiometricsScreen({super.key});

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends State<BiometricsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();
  final _authService = AuthService();
  
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController(); // NEW
  final _ageController = TextEditingController();
  
  String _selectedGender = 'male';
  String _selectedGoal = 'maintain';
  String _selectedActivityLevel = 'moderate';
  
  bool _isLoading = false;
  bool _isProgrammaticUpdate = false;
  UserBiometrics? _currentBiometrics;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
    _weightController.addListener(_updateGoalFromWeights);
    _targetWeightController.addListener(_updateGoalFromWeights);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometrics() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final biometrics = await _databaseService.getUserBiometrics(user.id);
      if (biometrics != null) {
        _isProgrammaticUpdate = true;
        setState(() {
          _currentBiometrics = biometrics;
          _heightController.text = biometrics.height.toStringAsFixed(1);
          _weightController.text = biometrics.weight.toStringAsFixed(1);
          _targetWeightController.text = biometrics.targetWeight?.toStringAsFixed(1) ?? '';
          _ageController.text = biometrics.age.toString();
          _selectedGender = biometrics.gender;
          _selectedGoal = biometrics.goal;
          _selectedActivityLevel = biometrics.activityLevel;
        });
        _isProgrammaticUpdate = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveBiometrics() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // The Model now auto-calculates BMI, BMR, TDEE, and Macros internally
      final biometrics = UserBiometrics(
        id: _currentBiometrics?.id, // Preserve ID if it exists
        userId: user.id,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        targetWeight: double.tryParse(_targetWeightController.text),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        goal: _selectedGoal,
        activityLevel: _selectedActivityLevel,
      );

      // Use the returned object from DB which includes generated fields like ID and timestamps
      final savedBiometrics = await _databaseService.saveUserBiometrics(biometrics);
      
      if (mounted) {
        setState(() {
          _currentBiometrics = savedBiometrics;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics updated!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Show the actual error to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BIOMETRICS')),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: AntiGravityTheme.meshColors)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_currentBiometrics != null) ...[
                    _buildResultsGrid(),
                    const SizedBox(height: 24),
                  ],
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('BMI', _currentBiometrics!.bmi.toStringAsFixed(1), Icons.monitor_weight)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('TDEE', '${_currentBiometrics!.tdee.toInt()} kcal', Icons.bolt)),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'DAILY GOAL', 
          '${_currentBiometrics!.dailyCalorieTarget.toInt()} kcal', 
          Icons.local_fire_department,
          subtitle: 'P: ${_currentBiometrics!.dailyProteinTarget.toInt()}g | C: ${_currentBiometrics!.dailyCarbsTarget.toInt()}g | F: ${_currentBiometrics!.dailyFatTarget.toInt()}g'
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return _buildDynamicGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('UPDATE PROFILE', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2)),
          const SizedBox(height: 24),
          _buildInput(_heightController, 'HEIGHT (cm)', Icons.height),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInput(_weightController, 'CURRENT (kg)', Icons.scale)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput(_targetWeightController, 'TARGET (kg)', Icons.flag_circle)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInput(_ageController, 'AGE', Icons.calendar_today),
          const SizedBox(height: 24),
          _buildLabel('GENDER'),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'male', label: Text('MALE')),
              ButtonSegment(value: 'female', label: Text('FEMALE')),
            ],
            selected: {_selectedGender},
            onSelectionChanged: (set) => setState(() => _selectedGender = set.first),
          ),
          const SizedBox(height: 24),
          _buildLabel('FITNESS GOAL'),
          _buildDropdown(['lean_bulk', 'bulk', 'cut', 'maintain'], _selectedGoal, (v) => setState(() => _selectedGoal = v!)),
          const SizedBox(height: 24),
          _buildLabel('ACTIVITY LEVEL'),
          _buildDropdown(['sedentary', 'light', 'moderate', 'active', 'very_active'], _selectedActivityLevel, (v) => setState(() => _selectedActivityLevel = v!)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveBiometrics,
            child: _isLoading ? const CircularProgressIndicator() : const Text('SAVE & CALCULATE'),
          ),
        ],
      ),
    );
  }

  // UI Helpers
  Widget _buildInput(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (double.tryParse(v) == null) return 'Invalid number';
        return null; // Input is valid
      },
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
  );

  Widget _buildDropdown(List<String> items, String current, Function(String?) onChanged) {
    // Ensure the current value is in the items list to prevent crash
    final safeValue = items.contains(current) ? current : items.first;

    return DropdownButtonFormField<String>(
      value: safeValue,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase().replaceAll('_', ' ')))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {String? subtitle}) {
    return _buildDynamicGlassCard(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.w600)),
          ]
        ],
      ),
    );
  }

  Widget _buildDynamicGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
  }

  void _updateGoalFromWeights() {
    if (_isProgrammaticUpdate) return;
    
    final current = double.tryParse(_weightController.text);
    final target = double.tryParse(_targetWeightController.text);
    
    if (current != null && target != null) {
      String newGoal = _selectedGoal;
      
      // Use small epsilon for float comparison logic
      final diff = target - current;
      
      if (diff < -0.1) { // Weight loss needed
         if (!_selectedGoal.contains('cut')) {
             newGoal = 'cut';
         }
      } else if (diff > 0.1) { // Weight gain needed
         if (!_selectedGoal.contains('bulk')) {
             newGoal = 'lean_bulk'; // Default to lean_bulk
         }
      } else { // Maintain (approx equal)
         if (_selectedGoal != 'maintain') {
             newGoal = 'maintain';
         }
      }
      
      if (newGoal != _selectedGoal) {
        setState(() => _selectedGoal = newGoal);
      }
    }
  }
}