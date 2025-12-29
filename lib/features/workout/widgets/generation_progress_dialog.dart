import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/generation_progress.dart';
import '../models/workout_plan.dart';

/// Shows real-time progress of workout plan generation.
/// 
/// Features:
/// - Live progress bar (0-100%)
/// - Status messages that update dynamically
/// - Day-by-day progress checklist
/// - Cancel button with proper cleanup
/// - Smooth animations between states
/// 
/// Usage:
/// ```dart
/// final plan = await showDialog<WorkoutPlan>(
///   context: context,
///   barrierDismissible: false,
///   builder: (context) => GenerationProgressDialog(
///     generationStream: repository.generateNewPlanStream(profile),
///   ),
/// );
/// ```
class GenerationProgressDialog extends StatefulWidget {
  final Stream<GenerationProgress> generationStream;
  final VoidCallback? onCancel;
  
  const GenerationProgressDialog({
    required this.generationStream,
    this.onCancel,
    super.key,
  });
  
  @override
  State<GenerationProgressDialog> createState() => _GenerationProgressDialogState();
}

class _GenerationProgressDialogState extends State<GenerationProgressDialog> 
    with SingleTickerProviderStateMixin {
  StreamSubscription<GenerationProgress>? _subscription;
  GenerationProgress _currentProgress = GenerationProgress.initial();
  List<DayProgress> _dayProgress = DayProgress.createWeek();
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _listenToStream();
  }
  
  void _listenToStream() {
    _subscription = widget.generationStream.listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _currentProgress = progress;
          _updateDayProgress(progress);
          
          // Close dialog when complete and return the plan
          if (progress.status == GenerationStatus.complete) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                Navigator.of(context).pop(progress.completePlan);
              }
            });
          }
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _currentProgress = GenerationProgress.error(error.toString());
        });
      },
    );
  }
  
  void _updateDayProgress(GenerationProgress progress) {
    if (progress.currentDay != null) {
      final dayIndex = progress.currentDay! - 1;
      
      // Update days list
      _dayProgress = List.generate(7, (i) {
        if (i < dayIndex) {
          return _dayProgress[i].copyWith(status: DayStatus.complete);
        } else if (i == dayIndex) {
          // Check if this day is complete based on message
          final isComplete = progress.message.contains('complete');
          return _dayProgress[i].copyWith(
            status: isComplete ? DayStatus.complete : DayStatus.generating,
          );
        } else {
          return _dayProgress[i].copyWith(status: DayStatus.pending);
        }
      });
    }
    
    // All days complete when status is complete
    if (progress.status == GenerationStatus.complete) {
      _dayProgress = _dayProgress.map((d) => d.copyWith(status: DayStatus.complete)).toList();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Progress Bar
            _buildProgressBar(),
            const SizedBox(height: 24),
            
            // Status Message
            _buildStatusMessage(),
            const SizedBox(height: 20),
            
            // Day Progress Checklist
            _buildDayChecklist(),
            const SizedBox(height: 20),
            
            // Cancel/Error Button
            _buildActionButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generating Your Workout',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '7-Day Personalized Plan',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressBar() {
    final progress = _currentProgress.progress;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation(
              _currentProgress.status == GenerationStatus.error 
                ? AppColors.accent 
                : AppColors.primary,
            ),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusMessage() {
    final isError = _currentProgress.status == GenerationStatus.error;
    final isComplete = _currentProgress.status == GenerationStatus.complete;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError 
          ? AppColors.accent.withValues(alpha: 0.1)
          : isComplete
            ? AppColors.secondary.withValues(alpha: 0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError 
            ? AppColors.accent.withValues(alpha: 0.3)
            : isComplete
              ? AppColors.secondary.withValues(alpha: 0.3)
              : AppColors.surfaceLight,
        ),
      ),
      child: Row(
        children: [
          _getStatusIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentProgress.message,
              style: TextStyle(
                color: isError
                  ? AppColors.accent
                  : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _getStatusIcon() {
    switch (_currentProgress.status) {
      case GenerationStatus.initializing:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
            strokeWidth: 2,
          ),
        );
      case GenerationStatus.generatingDay:
        return const Icon(Icons.psychology, color: AppColors.primary, size: 20);
      case GenerationStatus.validating:
        return const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 20);
      case GenerationStatus.complete:
        return const Icon(Icons.check_circle, color: AppColors.secondary, size: 20);
      case GenerationStatus.error:
        return const Icon(Icons.error, color: AppColors.accent, size: 20);
      case GenerationStatus.cancelled:
        return const Icon(Icons.cancel, color: AppColors.textSecondary, size: 20);
    }
  }
  
  Widget _buildDayChecklist() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dayProgress.length,
        itemBuilder: (context, index) {
          final day = _dayProgress[index];
          return _buildDayProgressItem(day);
        },
      ),
    );
  }
  
  Widget _buildDayProgressItem(DayProgress day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _getDayStatusIcon(day.status),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Day ${day.dayNumber}: ${day.dayName}',
              style: TextStyle(
                color: day.status == DayStatus.complete 
                    ? AppColors.textPrimary 
                    : day.status == DayStatus.generating
                        ? AppColors.primary
                        : AppColors.textSecondary,
                fontWeight: day.status == DayStatus.generating 
                    ? FontWeight.bold 
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          if (day.status == DayStatus.complete)
            const Icon(Icons.check, color: AppColors.secondary, size: 16),
        ],
      ),
    );
  }
  
  Widget _getDayStatusIcon(DayStatus status) {
    switch (status) {
      case DayStatus.pending:
        return Icon(
          Icons.radio_button_unchecked, 
          color: AppColors.textSecondary.withValues(alpha: 0.5), 
          size: 18,
        );
      case DayStatus.generating:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
            strokeWidth: 2,
          ),
        );
      case DayStatus.complete:
        return const Icon(Icons.check_circle, color: AppColors.secondary, size: 18);
    }
  }
  
  Widget _buildActionButton() {
    final isProcessing = _currentProgress.status == GenerationStatus.initializing ||
        _currentProgress.status == GenerationStatus.generatingDay ||
        _currentProgress.status == GenerationStatus.validating;
    
    final isError = _currentProgress.status == GenerationStatus.error;
    final isComplete = _currentProgress.status == GenerationStatus.complete;

    if (isComplete) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          widget.onCancel?.call();
          Navigator.of(context).pop();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          foregroundColor: isError ? AppColors.accent : AppColors.textSecondary,
        ),
        child: Text(
          isError ? 'Close' : 'Cancel Generation',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }
}
