import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/models/user_profile.dart';
import '../../session/repositories/session_repository.dart';

class DailyGoalCard extends StatelessWidget {
  final AsyncValue<UserProfile?> profileAsync;
  final AsyncValue<List<WorkoutSession>> sessionsAsync;

  const DailyGoalCard({
    super.key,
    required this.profileAsync,
    required this.sessionsAsync,
  });

  @override
  Widget build(BuildContext context) {
    // Compute a simple "daily goal" based on completed workouts today vs target
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    int completedToday = 0;
    sessionsAsync.whenData((sessions) {
      completedToday = sessions
          .where((s) {
            final d = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
            return d == todayKey && s.isCompleted;
          })
          .length;
    });

    int targetPerWeek = 4;
    profileAsync.whenData((profile) {
      if (profile != null) {
        // Rough mapping from fitness level to weekly target
        switch (profile.fitnessProfile.fitnessLevel.toLowerCase()) {
          case 'beginner':
            targetPerWeek = 3;
            break;
          case 'intermediate':
            targetPerWeek = 4;
            break;
          case 'advanced':
            targetPerWeek = 5;
            break;
          default:
            targetPerWeek = 4;
        }
      }
    });

    // Convert weekly target to a soft daily goal
    final double dailyTarget = targetPerWeek / 5; // assume 5 active days
    final double progress = (completedToday / dailyTarget).clamp(0.0, 1.0);
    final int progressPercent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "You're $progressPercent% to your\ndaily goal",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary, // Neon Lime
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt, color: Colors.black, size: 24),
              ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.05, 1.0),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ).animate().slideX(duration: 800.ms, curve: Curves.easeOutCubic, begin: -1),
              ),
              Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       "$progressPercent%",
                       style: GoogleFonts.inter(
                         fontSize: 12,
                         fontWeight: FontWeight.bold,
                         color: Colors.black,
                       ),
                     ),
                   ],
                 ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
             child: Text(
               "$completedToday workouts today",
               style: GoogleFonts.inter(
                 fontSize: 12,
                 color: AppColors.textSecondary,
                 fontWeight: FontWeight.w500,
               ),
             ),
          ),
        ],
      ),
    ).animate().fadeIn().moveY(begin: 20);
  }
}
