import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/auth_service.dart';
import '../theme/anti_gravity_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account created! Please check your email for verification.'),
              backgroundColor: AntiGravityTheme.pureWhite.withOpacity(0.2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AntiGravityTheme.meshColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: _isSignUp ? 600 : 550,
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
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Logo/Title
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: AntiGravityTheme.pureWhite,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FIT TRACK',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            letterSpacing: 3,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp ? 'CREATE ACCOUNT' : 'WELCOME BACK',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            letterSpacing: 2,
                            color: AntiGravityTheme.accentWhite,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AntiGravityTheme.pureWhite),
                          decoration: InputDecoration(
                            labelText: 'EMAIL',
                            labelStyle: const TextStyle(
                              color: AntiGravityTheme.accentWhite,
                              letterSpacing: 1.5,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AntiGravityTheme.accentWhite.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: AntiGravityTheme.darkGray.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AntiGravityTheme.pureWhite.withOpacity(0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AntiGravityTheme.pureWhite.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AntiGravityTheme.pureWhite,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AntiGravityTheme.pureWhite),
                          decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            labelStyle: const TextStyle(
                              color: AntiGravityTheme.accentWhite,
                              letterSpacing: 1.5,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: AntiGravityTheme.accentWhite.withOpacity(0.7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AntiGravityTheme.accentWhite.withOpacity(0.7),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: AntiGravityTheme.darkGray.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AntiGravityTheme.pureWhite.withOpacity(0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AntiGravityTheme.pureWhite.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AntiGravityTheme.pureWhite,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AntiGravityTheme.pureWhite.withOpacity(0.1),
                            foregroundColor: AntiGravityTheme.pureWhite,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AntiGravityTheme.pureWhite.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AntiGravityTheme.pureWhite),
                                  ),
                                )
                              : Text(
                                  _isSignUp ? 'SIGN UP' : 'SIGN IN',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Toggle Sign Up/Sign In
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isSignUp = !_isSignUp;
                                  });
                                },
                          child: Text(
                            _isSignUp
                                ? 'ALREADY HAVE AN ACCOUNT? SIGN IN'
                                : "DON'T HAVE AN ACCOUNT? SIGN UP",
                            style: TextStyle(
                              color: AntiGravityTheme.accentWhite.withOpacity(0.8),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
