import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_fitness_app/core/theme/app_theme.dart';
import 'package:ai_fitness_app/features/profile/screens/profile_screen.dart';
import 'package:ai_fitness_app/features/nutrition/models/meal.dart';
import 'package:ai_fitness_app/features/nutrition/repositories/nutrition_repository.dart';
import 'package:ai_fitness_app/features/session/repositories/session_repository.dart';
import 'package:ai_fitness_app/features/session/models/workout_session.dart';

class ProgressAnalyticsScreen extends ConsumerWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    final mealLogAsync = ref.watch(dailyLogProvider(normalized));
    final sessionsAsync = ref.watch(workoutSessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show date range picker
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Filter Period', style: TextStyle(color: AppColors.textPrimary)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Last Week', style: TextStyle(color: AppColors.textPrimary)),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Last Month', style: TextStyle(color: AppColors.textPrimary)),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Last 3 Months', style: TextStyle(color: AppColors.textPrimary)),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Last Year', style: TextStyle(color: AppColors.textPrimary)),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120), // Extra bottom padding for nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary section driven by Firestore-backed data
              sessionsAsync.when(
                data: (sessions) {
                  final completedThisMonth = _completedThisMonth(sessions);
                  final caloriesBurned = _estimateCaloriesBurned(sessions);
                  final streak = _computeStreak(sessions);

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Workouts',
                              value: '$completedThisMonth',
                              subtitle: 'This month',
                              icon: Icons.fitness_center,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Calories',
                              value: '$caloriesBurned',
                              subtitle: 'Estimated burned',
                              icon: Icons.local_fire_department,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: profileAsync.when(
                              data: (profile) {
                                final weight = profile?.bodyMetrics.weight ?? 0;
                                return _SummaryCard(
                                  title: 'Weight',
                                  value: weight.toStringAsFixed(1),
                                  subtitle: 'kg',
                                  icon: Icons.monitor_weight,
                                  color: AppColors.secondary,
                                );
                              },
                              loading: () => const _SummaryCard(
                                title: 'Weight',
                                value: '--',
                                subtitle: 'kg',
                                icon: Icons.monitor_weight,
                                color: AppColors.secondary,
                              ),
                              error: (_, __) => const _SummaryCard(
                                title: 'Weight',
                                value: '--',
                                subtitle: 'kg',
                                icon: Icons.monitor_weight,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Streak',
                              value: '$streak',
                              subtitle: 'Active days',
                              icon: Icons.local_fire_department,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, _) => Text(
                  'Failed to load workout analytics: $e',
                  style: const TextStyle(color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 32),
              
              // Workout Frequency Chart (NEW)
              Text('WORKOUT FREQUENCY', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 16),
              sessionsAsync.when(
                data: (sessions) => _WorkoutFrequencyChart(sessions: sessions),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, _) => Text(
                  'Unable to load frequency data: $e',
                  style: const TextStyle(color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 32),
              
              Text('WEIGHT HISTORY', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: profileAsync.when(
                  data: (profile) {
                    final weight = profile?.bodyMetrics.weight ?? 0;
                    final target = profile?.bodyMetrics.targetWeight ?? weight;
                    final List<double> data = [
                      weight.toDouble(),
                      target.toDouble(),
                    ];
                    return _WeightLineChart(data: data);
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (_, __) => const Center(
                    child: Text('Unable to load weight data', style: TextStyle(color: AppColors.accent)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Text('WORKOUT CONSISTENCY', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 16),
              sessionsAsync.when(
                data: (sessions) => _ConsistencyCalendar(sessions: sessions),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, _) => Text(
                  'Unable to load consistency data: $e',
                  style: const TextStyle(color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 32),
              
              Text('MACRO NUTRITION', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: mealLogAsync.when(
                  data: (log) => _MacroPieChart.fromMealLog(log),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Text(
                    'Unable to load nutrition data: $e',
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _completedThisMonth(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    return sessions
        .where((s) =>
            s.startTime.year == now.year &&
            s.startTime.month == now.month &&
            s.isCompleted)
        .length;
  }

  int _estimateCaloriesBurned(List<WorkoutSession> sessions) {
    // Very rough estimate: 8 kcal per minute of completed workout.
    return sessions
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + (s.duration.inMinutes * 8));
  }

  int _computeStreak(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;
    final daysWithWorkouts = <DateTime>{
      for (final s in sessions)
        DateTime(s.startTime.year, s.startTime.month, s.startTime.day),
    }.toList()
      ..sort();

    int streak = 0;
    DateTime currentDay = DateTime.now();

    while (true) {
      final dayOnly = DateTime(currentDay.year, currentDay.month, currentDay.day);
      if (daysWithWorkouts.contains(dayOnly)) {
        streak++;
        currentDay = currentDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}

class _WeightLineChart extends StatelessWidget {
  final List<double> data;
  
  const _WeightLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final minY = data.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = data.reduce((a, b) => a > b ? a : b) + 2;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.surfaceLight,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (val.toInt() < days.length) {
                    return Text(
                      days[val.toInt()],
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    );
                  }
                  return const Text('');
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  return Text(
                    val.toStringAsFixed(1),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  );
                },
                interval: 2,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: AppColors.background,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsistencyCalendar extends StatelessWidget {
  final List<WorkoutSession> sessions;
  
  const _ConsistencyCalendar({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    final workoutDays = <int>{};
    for (final s in sessions) {
      final d = s.startTime;
      if (d.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          d.month == now.month &&
          d.year == now.year) {
        workoutDays.add(d.day);
      }
    }

    final completed = workoutDays.length;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completed workouts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'This month',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department, color: AppColors.primary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Simple grid representation
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(daysInMonth, (index) {
              final dayNumber = index + 1;
              final hasWorkout = workoutDays.contains(dayNumber);
              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: hasWorkout 
                    ? AppColors.primary 
                    : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: hasWorkout 
                        ? AppColors.background 
                        : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroPieChart extends StatelessWidget {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const _MacroPieChart({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory _MacroPieChart.fromMealLog(MealLog log) {
    final total = log.totalMacros;
    return _MacroPieChart(
      calories: total.calories,
      protein: total.protein,
      carbs: total.carbs,
      fat: total.fat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalGrams = (protein + carbs + fat).clamp(1, 1000000);
    final proteinPct = (protein / totalGrams) * 100;
    final carbsPct = (carbs / totalGrams) * 100;
    final fatPct = (fat / totalGrams) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: proteinPct,
              title: '${proteinPct.toStringAsFixed(0)}%\nProtein',
              color: AppColors.primary,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.background,
              ),
            ),
            PieChartSectionData(
              value: carbsPct,
              title: '${carbsPct.toStringAsFixed(0)}%\nCarbs',
              color: AppColors.secondary,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.background,
              ),
            ),
            PieChartSectionData(
              value: fatPct,
              title: '${fatPct.toStringAsFixed(0)}%\nFat',
              color: AppColors.accent,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NEW: Workout Frequency Chart
class _WorkoutFrequencyChart extends StatelessWidget {
  final List<WorkoutSession> sessions;
  
  const _WorkoutFrequencyChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    // Get last 7 days of data
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });
    
    final Map<int, int> workoutsByDay = {};
    for (var day in last7Days) {
      final dayKey = DateTime(day.year, day.month, day.day);
      workoutsByDay[day.weekday] = sessions.where((s) {
        final sessionDay = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
        return sessionDay == dayKey && s.isCompleted;
      }).length;
    }

    final maxWorkouts = workoutsByDay.values.isEmpty 
        ? 5.0 
        : (workoutsByDay.values.reduce((a, b) => a > b ? a : b) + 1).toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxWorkouts,
          barGroups: last7Days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final count = workoutsByDay[day.weekday] ?? 0;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: count > 0 ? AppColors.primary : AppColors.surfaceLight,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                    final weekday = last7Days[value.toInt()].weekday;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        dayNames[weekday - 1],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.surfaceLight,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
