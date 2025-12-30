import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_fitness_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_fitness_app/features/session/models/workout_session.dart';

class ActivityGraphCard extends StatelessWidget {
  final AsyncValue<List<WorkoutSession>> sessionsAsync;

  const ActivityGraphCard({super.key, required this.sessionsAsync});

  @override
  Widget build(BuildContext context) {
    // Build 7‑day activity from latest sessions
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return DateTime(day.year, day.month, day.day);
    });

    final sessions = sessionsAsync.valueOrNull ?? [];

    if (sessionsAsync.hasError) {
      return _buildErrorState(context, sessionsAsync.error.toString());
    }

    final Map<DateTime, double> minutesPerDay = {
      for (final d in weekDays) d: 0.0,
    };

    for (final s in sessions) {
      if (!s.isCompleted) continue;
      final workoutDate = s.startTime.toLocal();
      for (final day in weekDays) {
        if (DateUtils.isSameDay(workoutDate, day)) {
          minutesPerDay[day] = minutesPerDay[day]! + (s.duration.inSeconds / 60.0);
          break;
        }
      }
    }

    final bars = weekDays
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final day = entry.value;
          final minutes = minutesPerDay[day] ?? 0;
          final double barHeight = minutes > 0 ? (minutes / 10).clamp(0.5, 12.0) : 0.0;
          return _makeGroupData(index, barHeight,
              isSelected: DateUtils.isSameDay(day, now));
        })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reports',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Container(
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
                children: [
                   Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                   const SizedBox(width: 8),
                   Text(
                     'Workout Minutes',
                     style: GoogleFonts.inter(
                       color: AppColors.textSecondary,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                   Text(
                     '${minutesPerDay.values.fold<double>(0, (a, b) => a + b).ceil()}',
                     style: GoogleFonts.outfit(
                       fontSize: 24,
                       fontWeight: FontWeight.bold,
                       color: AppColors.textPrimary,
                     ),
                   ),
                   const SizedBox(width: 6),
                    Text(
                     'min',
                     style: GoogleFonts.inter(
                       fontSize: 14,
                       color: AppColors.textSecondary,
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 150,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 12,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            );
                            String text;
                            switch (value.toInt()) {
                              case 0:
                                text = 'Mon';
                                break;
                              case 1:
                                text = 'Tue';
                                break;
                              case 2:
                                text = 'Wed';
                                break;
                              case 3:
                                text = 'Thu';
                                break;
                              case 4:
                                text = 'Fri';
                                break;
                              case 5:
                                text = 'Sat';
                                break;
                              case 6:
                                text = 'Sun';
                                break;
                              default:
                                text = '';
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(text, style: style),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: bars,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, {bool isSelected = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          width: 12,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 12,
            color: Colors.transparent, // Or a very faint track
          ),
        ),
      ],
    );
  }
  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chart data error: $error',
              style: GoogleFonts.inter(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
