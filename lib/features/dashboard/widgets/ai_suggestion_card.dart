import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/models/user_profile.dart';
import '../../session/repositories/session_repository.dart';
import '../services/ai_insights_service.dart';

class AiSuggestionCard extends ConsumerWidget {
  final AsyncValue<UserProfile?> profileAsync;

  const AiSuggestionCard({super.key, required this.profileAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = profileAsync.valueOrNull;
    final sessionsAsync = ref.watch(workoutSessionsStreamProvider);
    final aiInsights = ref.watch(aiInsightsServiceProvider);

    String suggestion = 'Loading insights...';
    
    sessionsAsync.whenData((sessions) {
      suggestion = aiInsights.generateDailySuggestion(
        profile: profile,
        recentSessions: sessions,
      );
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Coach Insight',
                style: GoogleFonts.inter(
                  color: AppColors.secondary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          sessionsAsync.when(
            data: (_) => Text(
              suggestion,
              style: GoogleFonts.outfit(
                color: AppColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            loading: () => const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, __) => Text(
              'Unable to load insights. Check back soon!',
              style: GoogleFonts.outfit(
                color: AppColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh,
                  color: AppColors.secondary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Updates after each workout',
                  style: GoogleFonts.inter(
                    color: AppColors.secondary.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
