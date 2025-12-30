import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_fitness_app/core/theme/app_theme.dart';
import 'package:ai_fitness_app/features/profile/models/user_profile.dart';
import 'package:ai_fitness_app/features/session/models/workout_session.dart';

class DailyOverviewCard extends StatelessWidget {
  final AsyncValue<UserProfile?> profileAsync;
  final AsyncValue<List<WorkoutSession>> sessionsAsync;

  const DailyOverviewCard({
    super.key,
    required this.profileAsync,
    required this.sessionsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final sessions = sessionsAsync.valueOrNull ?? [];
    final profile = profileAsync.valueOrNull;

    if (sessionsAsync.hasError) {
      return _buildErrorState(context, sessionsAsync.error.toString());
    }

    final todaySessions = sessions.where((s) {
      final workoutDate = s.startTime.toLocal();
      return DateUtils.isSameDay(workoutDate, today) && s.isCompleted;
    }).toList();

    final totalSecondsToday =
        todaySessions.fold<int>(0, (sum, s) => sum + s.duration.inSeconds);

    final totalMinutesTodayFloat = totalSecondsToday / 60.0;
    final displayMinutes = totalMinutesTodayFloat.ceil();

    // Very rough calories estimate: 8 kcal per active minute
    final caloriesToday = (totalMinutesTodayFloat * 8).round();

    final waterGoal = profile?.nutritionProfile.waterIntakeGoal ?? 2.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Activity',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            TextButton(
              onPressed: () => context.push('/progress'),
              child: Text(
                'Analytics >',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _OverviewTile(
                icon: Icons.local_fire_department_rounded,
                title: 'Active\nCalories',
                value: caloriesToday.toString(),
                unit: 'Cal',
                color: AppColors.primary,
                delay: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OverviewTile(
                icon: Icons.timer_outlined,
                title: 'Workout\nTime',
                value: displayMinutes.toString(),
                unit: 'min',
                color: AppColors.secondary,
                delay: 100,
              ),
            ),
          ],
        ),
        // Add more rows if needed, or keep it 2x1 for now as per image section
        // Image shows 2 large square tiles "Active Calories" and "Total Distance" in one screenshot (middle).
        // Left screenshot shows "Steps" graph and "Daily Activity" with small tiles.
        // Let's stick to 2x2 grid if we have data, or just these 2 for now.
        // I will add the second row back for Steps and Water/Heart Rate.
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _OverviewTile(
                icon: Icons.monitor_heart_rounded,
                title: 'Heart\nRate',
                value: todaySessions.isEmpty ? '--' : '↑',
                unit: todaySessions.isEmpty ? 'No data' : 'Post-workout',
                color: AppColors.accent,
                delay: 200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OverviewTile(
                icon: Icons.water_drop_rounded,
                title: 'Water\nIntake',
                value: waterGoal.toString(),
                unit: 'Liters',
                color: AppColors.primary,
                delay: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;
  final int delay;

  const _OverviewTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).scale(curve: Curves.easeOutBack);
  }
}

Widget _buildErrorState(BuildContext context, String error) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Failed to load activity: $error',
            style: GoogleFonts.inter(color: AppColors.accent, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
