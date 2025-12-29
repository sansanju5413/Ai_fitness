import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../profile/repositories/profile_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  bool _hasError = false;
  String _errorMessage = '';

  Future<void> _initializeApp() async {
    if (!mounted) return;
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final bool localOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // Navigate based on onboarding, auth, and profile state
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!localOnboarding) {
          context.go('/onboarding');
        } else {
          context.go('/login');
        }
        return;
      }

      final profileRepo = ref.read(profileRepositoryProvider);
      final profile = await profileRepo.getProfile();

      if (!mounted) return;

      if (profile == null) {
        context.go('/profile-setup');
        return;
      }

      // Check cloud onboarding status
      if (!profile.hasSeenOnboarding && !localOnboarding) {
        context.go('/onboarding');
      } else if (!profile.isProfileComplete) {
        context.go('/profile-setup');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo Placeholder using Icon
                          const Icon(
                            Icons.fitness_center_rounded,
                            size: 80,
                            color: AppColors.secondary,
                          )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)) // Pulsating effect
                          .then() // Run 'shimmer' after 'scale'
                          .shimmer(duration: 2000.ms, color: AppColors.secondary.withValues(alpha: 0.5)),
            
                          const SizedBox(height: 24),
                          
                          Text(
                            'AI FITNESS',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              letterSpacing: 1.5,
                            ),
                          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Your Personal AI Coach',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
            
                          const SizedBox(height: 48),
            
                          if (_hasError) ...[
                            const Icon(Icons.error_outline, color: AppColors.accent, size: 48),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Initialization Failed\n$_errorMessage',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.accent),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _initializeApp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                foregroundColor: AppColors.primary,
                              ),
                              child: const Text('Retry'),
                            )
                          ] else ...[
                            // Loading Indicator
                            const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                            ).animate().fadeIn(delay: 1000.ms),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              'Initializing...',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ).animate().fadeIn(delay: 1000.ms),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
