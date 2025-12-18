import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/profile/screens/profile_setup_screen.dart';
import '../../features/profile/screens/ai_analysis_screen.dart';
import '../../features/workout/screens/workout_plans_screen.dart';
import '../../features/workout/screens/exercise_library_screen.dart';

import '../../features/dashboard/screens/home_screen.dart';
import '../../features/session/screens/workout_session_screen.dart';
import '../../features/session/screens/guided_workout_screen.dart';
import '../../features/workout/models/workout_plan.dart'; // For DailyWorkout type cast

import '../../features/nutrition/screens/nutrition_dashboard_screen.dart';
import '../../features/nutrition/screens/food_logger_screen.dart';

import '../../features/profile/screens/progress_analytics_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

import '../../features/dashboard/screens/main_scaffold.dart';
import '../theme/app_theme.dart';
// Placeholder removed


final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/ai-analysis',
      builder: (context, state) => const AiAnalysisScreen(),
    ),
    
    // Main App Shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/workouts',
          builder: (context, state) => const WorkoutPlansScreen(),
        ),
        GoRoute(
          path: '/diet',
          builder: (context, state) => const NutritionDashboardScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressAnalyticsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // Sub-pages (Hide Bottom Nav)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/exercises',
      builder: (context, state) => const ExerciseLibraryScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/session',
      builder: (context, state) {
        final workout = state.extra as DailyWorkout?;
        if (workout == null) {
          // Handle null case - redirect to workouts or show error
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.accent),
                    const SizedBox(height: 16),
                    const Text(
                      'No workout selected',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => GoRouter.of(context).go('/workouts'),
                      child: const Text('Go to Workouts'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return WorkoutSessionScreen(workout: workout);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/log-food',
      builder: (context, state) => const FoodLoggerScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/guided-workout',
      builder: (context, state) {
        final workout = state.extra as DailyWorkout?;
        if (workout == null) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.accent),
                    const SizedBox(height: 16),
                    const Text(
                      'No workout selected',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => GoRouter.of(context).go('/workouts'),
                      child: const Text('Go to Workouts'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return GuidedWorkoutScreen(workout: workout);
      },
    ),
  ],
);


