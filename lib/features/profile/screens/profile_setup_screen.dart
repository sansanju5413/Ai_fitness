import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_form_provider.dart';
import '../widgets/step_widgets.dart'; // We'll create this next

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    ref.read(profileFormProvider.notifier).nextStep();
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    ref.read(profileFormProvider.notifier).previousStep();
  }

  Future<void> _submit() async {
    // Navigate to AI Analysis screen
    // Submitting handled in AI screen to show loading state
     context.go('/ai-analysis');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileFormProvider);
    final isLastStep = state.currentStep == 4;

    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Profile (${state.currentStep + 1}/5)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: state.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (state.currentStep + 1) / 5,
              backgroundColor: AppColors.surfaceLight,
              color: AppColors.secondary,
            ).animate().fadeIn(),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: const [
                  Step1BasicInfo(),
                  Step2BodyMetrics(),
                  Step3FitnessProfile(),
                  Step4NutritionProfile(),
                  Step5HealthLifestyle(),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.currentStep > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  ElevatedButton(
                    onPressed: isLastStep ? _submit : _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: isLastStep ? AppColors.secondary : AppColors.primary,
                    ),
                    child: Text(isLastStep ? 'Analyze My Profile' : 'Next Step'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
