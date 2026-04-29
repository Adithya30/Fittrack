import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/workout_plan.dart';
import '../theme/anti_gravity_theme.dart';

class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({super.key});

  @override
  State<WorkoutTrackerScreen> createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen> {
  final _geminiService = GeminiService();
  final _databaseService = DatabaseService();
  final _authService = AuthService();

  DateTime _selectedDate = DateTime.now();
  WorkoutPlan? _currentPlan;
  bool _isLoading = false;
  
  // Local tracking of completed days (In a real app, load this from DB)
  final Set<DateTime> _completedDays = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    // TODO: Load saved plan from DatabaseService if available
    // For now, we will generate one if none exists locally
    if (_currentPlan == null) {
      _generateNewPlan();
    }
  }

  Future<void> _generateNewPlan() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final biometrics = await _databaseService.getUserBiometrics(user.id);
      if (biometrics != null) {
        final plan = await _geminiService.generateWorkoutPlan(biometrics: biometrics);
        setState(() => _currentPlan = plan);
        // TODO: Save plan to Database
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WORKOUT TRACKER')),
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCalendarCard(),
                const SizedBox(height: 24),
                _buildWorkoutCard(),
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

  Widget _buildCalendarCard() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    return _buildGlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthName(now.month)} ${now.year}'.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2),
              ),
              Icon(Icons.calendar_today, color: AntiGravityTheme.pureWhite.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + (firstWeekday - 1),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox();
              
              final day = index - (firstWeekday - 1) + 1;
              final date = DateTime(now.year, now.month, day);
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isToday = DateUtils.isSameDay(date, now);
              final isCompleted = _completedDays.any((d) => DateUtils.isSameDay(d, date));

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AntiGravityTheme.pureWhite 
                        : isCompleted 
                            ? Colors.green.withOpacity(0.5) 
                            : AntiGravityTheme.pureWhite.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday ? Border.all(color: Colors.blueAccent, width: 2) : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.black : AntiGravityTheme.pureWhite,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentPlan == null) {
      return _buildGlassCard(
        child: Center(
          child: ElevatedButton(
            onPressed: _generateNewPlan,
            child: const Text('GENERATE WEEKLY SPLIT'),
          ),
        ),
      );
    }

    // Map selected date to day of week (0 = Mon, 6 = Sun in list index if aligned)
    // DateTime.weekday returns 1 for Mon, 7 for Sun.
    final dayIndex = _selectedDate.weekday - 1;
    final dailyWorkout = _currentPlan!.schedule.length > dayIndex 
        ? _currentPlan!.schedule[dayIndex] 
        : null;

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dailyWorkout?.day.toUpperCase() ?? 'REST DAY',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      dailyWorkout?.focus ?? 'Recovery',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Generate New Split',
                onPressed: _generateNewPlan,
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          if (dailyWorkout != null && dailyWorkout.exercises.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyWorkout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = dailyWorkout.exercises[index];
                return CheckboxListTile(
                  title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${exercise.sets} Sets x ${exercise.reps} Reps'),
                  value: exercise.isCompleted,
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) {
                    setState(() {
                      exercise.isCompleted = val ?? false;
                      _checkDailyCompletion(dailyWorkout);
                    });
                  },
                );
              },
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No exercises scheduled for today. Enjoy your rest!'),
            ),
        ],
      ),
    );
  }

  void _checkDailyCompletion(WorkoutDay workout) {
    final allDone = workout.exercises.every((e) => e.isCompleted);
    if (allDone) {
      _completedDays.add(_selectedDate);
    } else {
      _completedDays.remove(_selectedDate);
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}