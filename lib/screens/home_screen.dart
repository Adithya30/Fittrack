import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_biometrics.dart';
import '../theme/anti_gravity_theme.dart';
import 'biometrics_screen.dart';
import 'nutrition_coach_screen.dart';
import 'login_screen.dart';
import 'workout_tracker_screen.dart';
import 'food_tracker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  UserBiometrics? _biometrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final biometrics = await _databaseService.getUserBiometrics(user.id);
      setState(() {
        _biometrics = biometrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIT TRACK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Section
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 200,
                        borderRadius: 24,
                        blur: 25,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AntiGravityTheme.pureWhite.withOpacity(0.15),
                            AntiGravityTheme.pureWhite.withOpacity(0.05),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AntiGravityTheme.pureWhite.withOpacity(0.4),
                            AntiGravityTheme.pureWhite.withOpacity(0.1),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: AntiGravityTheme.pureWhite,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'WELCOME',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  letterSpacing: 3,
                                ),
                              ),
                              if (_authService.currentUser != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _authService.currentUser!.email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quick Stats (if biometrics exist)
                      if (_biometrics != null) ...[
                        _buildQuickStatCard(
                          'BMI',
                          _biometrics!.bmi.toStringAsFixed(1),
                          Icons.monitor_weight,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickStatCard(
                                'BMR',
                                '${_biometrics!.bmr.toStringAsFixed(0)}',
                                Icons.local_fire_department,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickStatCard(
                                'TDEE',
                                '${_biometrics!.tdee.toStringAsFixed(0)}',
                                Icons.bolt,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Navigation Cards
                      _buildNavigationCard(
                        title: 'BIOMETRICS',
                        subtitle: _biometrics == null
                            ? 'Set up your profile'
                            : 'Update your metrics',
                        icon: Icons.person_outline,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BiometricsScreen(),
                            ),
                          );
                          _loadBiometrics();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNavigationCard(
                        title: 'NUTRITION COACH',
                        subtitle: 'AI-powered Kerala recipes',
                        icon: Icons.restaurant_menu,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AntiGravityTheme.pureWhite.withOpacity(0.2),
                            AntiGravityTheme.pureWhite.withOpacity(0.1),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NutritionCoachScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNavigationCard(
                        title: 'WORKOUT TRACKER',
                        subtitle: 'Your weekly training plan',
                        icon: Icons.fitness_center,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AntiGravityTheme.pureWhite.withOpacity(0.2),
                            AntiGravityTheme.pureWhite.withOpacity(0.1),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkoutTrackerScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNavigationCard(
                        title: 'FOOD TRACKER',
                        subtitle: 'Log meals & track macros',
                        icon: Icons.pie_chart_outline,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AntiGravityTheme.pureWhite.withOpacity(0.2),
                            AntiGravityTheme.pureWhite.withOpacity(0.1),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FoodTrackerScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(String label, String value, IconData icon) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
      borderRadius: 16,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AntiGravityTheme.pureWhite.withOpacity(0.1),
          AntiGravityTheme.pureWhite.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AntiGravityTheme.pureWhite.withOpacity(0.3),
          AntiGravityTheme.pureWhite.withOpacity(0.1),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AntiGravityTheme.pureWhite, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Gradient? gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 120,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: gradient as LinearGradient? ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AntiGravityTheme.pureWhite.withOpacity(0.15),
                  AntiGravityTheme.pureWhite.withOpacity(0.05),
                ],
              ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AntiGravityTheme.pureWhite.withOpacity(0.4),
              AntiGravityTheme.pureWhite.withOpacity(0.1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AntiGravityTheme.pureWhite.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AntiGravityTheme.pureWhite.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AntiGravityTheme.pureWhite,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AntiGravityTheme.pureWhite.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
