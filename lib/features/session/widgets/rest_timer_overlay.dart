import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/session_provider.dart';

class RestTimerOverlay extends ConsumerWidget {
  const RestTimerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    
    if (!sessionState.isResting) return const SizedBox.shrink();

    return Container(
      color: AppColors.background.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('REST', style: TextStyle(color: AppColors.textSecondary, letterSpacing: 4)),
            const SizedBox(height: 20),
            Text(
              '${sessionState.restTimeRemaining}',
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ).animate(key: ValueKey(sessionState.restTimeRemaining)).scale(duration: 200.ms),
            const SizedBox(height: 40),
            OutlinedButton(
               onPressed: () => ref.read(sessionProvider.notifier).skipRest(),
               style: OutlinedButton.styleFrom(
                 side: const BorderSide(color: AppColors.secondary),
                 foregroundColor: AppColors.secondary,
                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
               ),
               child: const Text("Skip Rest"),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}
