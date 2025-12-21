import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../models/workout_plan.dart';

class ExerciseDetailView extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailView({super.key, required this.exercise});

  @override
  State<ExerciseDetailView> createState() => _ExerciseDetailViewState();
}

class _ExerciseDetailViewState extends State<ExerciseDetailView> {
  int _currentSlideIndex = 0;

  String _getExerciseImage(String exerciseName) {
    final name = exerciseName.toLowerCase();
    if (name.contains('push-up') || name.contains('chest')) {
      return 'assets/images/download.jpg';
    } else if (name.contains('squat') || name.contains('leg')) {
      return 'assets/images/download_1.jpg';
    } else if (name.contains('dumbbell') || name.contains('arm') || name.contains('curl')) {
      return 'assets/images/Symactive_10Kg_Adjustable_Dumbbell_Set___PVC_Weights_plus_14_Rod_Pair___Home_Workout_Kit___Black.jpg';
    } else if (name.contains('cycle') || name.contains('bike')) {
      return 'assets/images/Schwinn_IC3_Indoor_Cycling_Bike_Review.jpg';
    } else if (name.contains('stretch') || name.contains('yoga')) {
      return 'assets/images/Beginners_Workout_Plan_for_Weight_Gain_at_Home.jpg';
    }
    return 'assets/images/Dangerous_jim_for_visit.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.exercise.instructionSlides;
    final hasMultipleSlides = slides.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handlebar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Exercise Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        _getExerciseImage(widget.exercise.name),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 24),

                    // Exercise Name
                    Text(
                      widget.exercise.name,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Metrics Row
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _MetricChip(label: 'Sets', value: widget.exercise.sets.toString()),
                        _MetricChip(label: 'Reps', value: widget.exercise.reps.toString()),
                        _MetricChip(label: 'Rest', value: '${widget.exercise.restSeconds}s'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Instruction Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      constraints: const BoxConstraints(minHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        slides[_currentSlideIndex],
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ).animate(key: ValueKey(_currentSlideIndex)).fadeIn().slideX(begin: 0.1),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Controls (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: hasMultipleSlides
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NavButton(
                          icon: Icons.arrow_back,
                          label: 'Back',
                          onTap: _currentSlideIndex > 0
                              ? () => setState(() => _currentSlideIndex--)
                              : null,
                        ),
                        Text(
                          '${_currentSlideIndex + 1} / ${slides.length}',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        _NavButton(
                          icon: Icons.arrow_forward,
                          label: 'Next',
                          isPrimary: true,
                          onTap: _currentSlideIndex < slides.length - 1
                              ? () => setState(() => _currentSlideIndex++)
                              : null,
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _NavButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.transparent
              : (isPrimary ? AppColors.primary : AppColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: AppColors.surfaceLight),
        ),
        child: Row(
          children: [
            if (icon == Icons.arrow_back) ...[
              Icon(icon, size: 18, color: isDisabled ? AppColors.textSecondary.withValues(alpha: 0.3) : (isPrimary ? Colors.black : AppColors.primary)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? AppColors.textSecondary.withValues(alpha: 0.3) : (isPrimary ? Colors.black : AppColors.textPrimary),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (icon == Icons.arrow_forward) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: isDisabled ? AppColors.textSecondary.withValues(alpha: 0.3) : (isPrimary ? Colors.black : AppColors.primary)),
            ],
          ],
        ),
      ),
    );
  }
}
