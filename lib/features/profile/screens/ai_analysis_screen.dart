import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_form_provider.dart';
import '../repositories/profile_repository.dart';
import '../models/user_profile.dart';

class AiAnalysisScreen extends ConsumerStatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen> {
  String? _analysisResult;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final state = ref.read(profileFormProvider);
      
      // Save profile if user is logged in
      if (uid != null) {
        await ref.read(profileFormProvider.notifier).submitProfile(uid);
      }
      
      // Construct UserProfile from form state
      final profile = UserProfile(
        uid: uid ?? 'demo_user',
        basicInfo: BasicInfo(
          fullName: state.fullName.isEmpty ? 'User' : state.fullName,
          age: state.age,
          gender: state.gender,
        ),
        bodyMetrics: BodyMetrics(
          height: state.height,
          weight: state.weight,
          targetWeight: state.targetWeight,
          bodyType: 'Mesomorph', // Could be calculated
        ),
        fitnessProfile: FitnessProfile(
          primaryGoal: state.primaryGoal,
          fitnessLevel: state.fitnessLevel,
          activityLevel: state.activityLevel,
          availableEquipment: state.availableEquipment,
          workoutLocation: 'Home',
          durationPreference: '45 mins',
        ),
        nutritionProfile: NutritionProfile(
          dietaryPreference: state.dietaryPreference,
          allergies: state.allergies,
          mealsPerDay: state.mealsPerDay,
          waterIntakeGoal: state.waterIntakeGoal,
        ),
        healthLifestyle: HealthLifestyle(
          medicalConditions: state.medicalConditions,
          injuries: state.injuries,
          sleepHours: state.sleepHours,
          stressLevel: state.stressLevel,
        ),
        isProfileComplete: true,
      );
      
      // Generate AI Assessment using Gemini
      final repo = ref.read(profileRepositoryProvider);
      final assessment = await repo.generateAiAssessment(profile);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _analysisResult = assessment;
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          _analysisResult = 'Failed to generate AI assessment. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) ...[
                const Icon(Icons.psychology, size: 80, color: AppColors.secondary)
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1.5.seconds, color: AppColors.secondary),
                const SizedBox(height: 32),
                Text(
                  'AI Coach is analyzing your profile...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(),
                const SizedBox(height: 16),
                Text(
                  'Calculating metabolic rate...\nDesigning workout split...\nOptimizing nutrition plan...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: AppColors.primary),
              ] else ...[
                const Icon(Icons.check_circle_outline, size: 80, color: AppColors.primary)
                    .animate()
                    .scale()
                    .fadeIn(),
                const SizedBox(height: 32),
                Text(
                  'Your Personalized Plan is Ready!',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceLight),
                      ),
                      child: _analysisResult != null
                          ? Text(
                              _analysisResult!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    color: AppColors.textPrimary,
                                  ),
                            )
                          : Text(
                              _errorMessage ?? 'No assessment available',
                              style: const TextStyle(color: AppColors.accent),
                            ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text("Go to Dashboard"),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
