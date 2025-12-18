import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/daily_overview_card.dart';
import '../widgets/ai_suggestion_card.dart';
import '../widgets/activity_graph_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../../profile/screens/profile_screen.dart';
import '../../session/repositories/session_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);
    final sessionsAsync = ref.watch(workoutSessionsStreamProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Invalidate providers to force refresh
            ref.invalidate(profileStreamProvider);
            ref.invalidate(workoutSessionsStreamProvider);
            // Wait a bit for streams to refresh
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                const SizedBox(height: 32),
                DailyGoalCard(
                  profileAsync: profileAsync,
                  sessionsAsync: sessionsAsync,
                ),
                const SizedBox(height: 32),
                const QuickActionsGrid(),
                const SizedBox(height: 32),
                AiSuggestionCard(profileAsync: profileAsync),
                const SizedBox(height: 32),
                ActivityGraphCard(sessionsAsync: sessionsAsync),
                const SizedBox(height: 32),
                DailyOverviewCard(
                  profileAsync: profileAsync,
                  sessionsAsync: sessionsAsync,
                ),
                const SizedBox(height: 100), // Bottom padding for floating nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
