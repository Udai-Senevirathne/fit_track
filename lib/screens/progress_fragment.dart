import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../data/database/database_helper.dart';
import '../services/achievement_service.dart';
import '../models/weight_entry.dart';
import '../models/workout.dart';
import '../config/app_theme.dart';

class ProgressFragment extends StatefulWidget {
  const ProgressFragment({super.key});

  @override
  State<ProgressFragment> createState() => _ProgressFragmentState();
}

class _ProgressFragmentState extends State<ProgressFragment> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AchievementService _achievementService = AchievementService();
  final _uuid = const Uuid();
  List<WeightEntry> weightEntries = [];
  List<Workout> workouts = [];

  // Stream subscriptions for real-time updates
  late StreamSubscription<List<WeightEntry>> _weightEntriesSubscription;
  late StreamSubscription<List<Workout>> _workoutsSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToUpdates();
  }

  @override
  void dispose() {
    _weightEntriesSubscription.cancel();
    _workoutsSubscription.cancel();
    super.dispose();
  }

  void _subscribeToUpdates() {
    // Listen to real-time weight entries updates
    _weightEntriesSubscription = _databaseHelper.weightEntriesStream.listen((
      entries,
    ) {
      if (mounted) {
        setState(() {
          weightEntries = entries;
        });
      }
    });

    // Listen to real-time workouts updates
    _workoutsSubscription = _databaseHelper.workoutsStream.listen((
      workoutList,
    ) {
      if (mounted) {
        setState(() {
          workouts = workoutList;
        });
      }
    });
  }

  Future<void> _loadData() async {
    print('🔄 Loading progress data...');
    // Trigger initial data loading which will emit to streams
    await _databaseHelper.getAllWeightEntries();
    await _databaseHelper.getAllWorkouts();

    print('📊 Weight entries count: ${weightEntries.length}');
    print('🏋️ Workouts count: ${workouts.length}');

    // Debug: Add sample data if completely empty
    if (weightEntries.isEmpty && workouts.isEmpty) {
      print('🔧 Adding sample data for demo...');
      await _addSampleData();
    }
  }

  Future<void> _addSampleData() async {
    try {
      // Add some sample weight entries over the past week
      final now = DateTime.now();
      final sampleWeights = [
        {'days': 7, 'weight': 44.5},
        {'days': 5, 'weight': 44.8},
        {'days': 3, 'weight': 45.0},
        {'days': 1, 'weight': 45.2},
      ];

      for (final sample in sampleWeights) {
        final entry = WeightEntry(
          id: _uuid.v4(),
          weight: sample['weight'] as double,
          date: now.subtract(Duration(days: sample['days'] as int)),
          notes: 'Sample entry',
        );
        await _databaseHelper.insertWeightEntry(entry);
      }

      print('✅ Sample weight entries added');
    } catch (e) {
      print('❌ Error adding sample data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accentGreen,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Progress Analytics Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: _buildProgressAnalyticsCard(),
              ),
            ),
            // Performance Dashboard
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: _buildPerformanceDashboard(),
              ),
            ),
            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildChartsSection(),
                    const SizedBox(height: 32),
                    _buildRecentActivities(),
                    const SizedBox(height: 120), // Extra space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildEnhancedFAB(),
    );
  }

  Widget _buildProgressAnalyticsCard() {
    final completedWorkouts = workouts.where((w) => w.endTime != null).length;
    final currentWeight = weightEntries.isNotEmpty
        ? weightEntries.last.weight
        : 0.0;
    final streak = _calculateStreak();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00C851), // Bright green
            Color(0xFF10B981), // Emerald green
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C851).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Your fitness evolution',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats
          Row(
            children: [
              _buildAnalyticsStatItem(
                icon: Icons.fitness_center_rounded,
                value: completedWorkouts.toString(),
                label: 'Workouts',
              ),
              const SizedBox(width: 24),
              _buildAnalyticsStatItem(
                icon: Icons.monitor_weight_rounded,
                value: currentWeight > 0
                    ? '${currentWeight.toStringAsFixed(1)}kg'
                    : '--',
                label: 'Weight',
              ),
              const SizedBox(width: 24),
              _buildAnalyticsStatItem(
                icon: Icons.local_fire_department_rounded,
                value: streak.toString(),
                label: 'Day Streak',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C851), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Performance Dashboard',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Performance cards
        _buildPerformanceCards(),
      ],
    );
  }

  Widget _buildPerformanceCards() {
    final completedWorkouts = workouts.where((w) => w.endTime != null).length;
    final totalSets = workouts.fold<int>(0, (sum, w) => sum + w.sets.length);
    final currentWeight = weightEntries.isNotEmpty
        ? weightEntries.last.weight
        : 0.0;

    final performanceData = [
      {
        'title': 'Total\nWorkouts',
        'value': completedWorkouts.toString(),
        'gradient': [Color(0xFFFF6B35), Color(0xFFF7931E)],
      },
      {
        'title': 'Sets\nCompleted',
        'value': totalSets.toString(),
        'gradient': [Color(0xFFE91E63), Color(0xFF9C27B0)],
      },
      {
        'title': 'Current\nWeight',
        'value': currentWeight > 0
            ? '${currentWeight.toStringAsFixed(1)}kg'
            : '--',
        'gradient': [Color(0xFF2196F3), Color(0xFF00BCD4)],
      },
      {
        'title': 'Streak\nRecord',
        'value': '${_calculateStreak()}',
        'gradient': [Color(0xFF4CAF50), Color(0xFF8BC34A)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: performanceData.length,
      itemBuilder: (context, index) {
        final data = performanceData[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: data['gradient'] as List<Color>,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (data['gradient'] as List<Color>)[0].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                data['value'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['title'] as String,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppTheme.infoGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Analytics Overview',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        // Charts
        _buildWeightChart(),
        const SizedBox(height: 24),
        _buildWorkoutChart(),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppTheme.primaryGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Activities',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        _buildRecentEntries(),
      ],
    );
  }

  Widget _buildEnhancedFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.progressGradient[0],
            AppTheme.progressGradient[1],
            AppTheme.neonGreen,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.progressGradient[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppTheme.neonGreen.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: "progress_fab_enhanced",
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showEnhancedAddWeightDialog();
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
        ),
        label: Text(
          'Log Weight',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    if (weightEntries.isEmpty) {
      return _buildEmptyChart(
        'Weight Progress',
        'Start tracking your weight to see progress',
      );
    }

    return AppTheme.buildAnimatedCard(
      backgroundColor: AppTheme.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppTheme.cardDecoration(
                  gradient: AppTheme.progressGradient,
                  borderRadius: 16,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.lightText,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text('Weight Progress', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.mutedText.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}kg',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < weightEntries.length) {
                          final date = weightEntries[value.toInt()].date;
                          return Text(
                            DateFormat('MM/dd').format(date),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryText,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightEntries.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.weight);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(colors: AppTheme.progressGradient),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: AppTheme.cardBackground,
                          strokeWidth: 3,
                          strokeColor: AppTheme.progressGradient[0],
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.progressGradient[0].withValues(alpha: 0.3),
                          AppTheme.progressGradient[0].withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutChart() {
    if (workouts.isEmpty) {
      return _buildEmptyChart(
        'Workout Frequency',
        'Complete workouts to see your activity',
      );
    }

    final last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    final workoutCounts = last7Days.map((day) {
      return workouts
          .where((workout) {
            return workout.endTime != null &&
                workout.endTime!.day == day.day &&
                workout.endTime!.month == day.month &&
                workout.endTime!.year == day.year;
          })
          .length
          .toDouble();
    }).toList();

    return AppTheme.buildAnimatedCard(
      backgroundColor: AppTheme.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppTheme.cardDecoration(
                  gradient: AppTheme.successGradient,
                  borderRadius: 16,
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppTheme.lightText,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text('Weekly Activity', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: workoutCounts.isNotEmpty
                    ? workoutCounts.reduce((a, b) => a > b ? a : b) + 1
                    : 5,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppTheme.cardBackground,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()} workouts',
                        AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryText,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        final dayIndex =
                            (DateTime.now().weekday - 1 + value.toInt()) % 7;
                        return Text(
                          days[dayIndex],
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.mutedText.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: workoutCounts.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: AppTheme.successGradient,
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries() {
    if (weightEntries.isEmpty) {
      return AppTheme.buildEmptyState(
        icon: Icons.monitor_weight_outlined,
        title: 'No weight entries yet',
        message: 'Start tracking your weight to see your progress',
      );
    }

    return AppTheme.buildAnimatedCard(
      backgroundColor: AppTheme.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppTheme.cardDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: 16,
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppTheme.lightText,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text('Recent Entries', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 20),
          ...weightEntries
              .take(5)
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.cardDecoration(
                      gradient: null,
                      borderRadius: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: AppTheme.cardDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: 12,
                          ),
                          child: const Icon(
                            Icons.monitor_weight_outlined,
                            color: AppTheme.lightText,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.weight.toStringAsFixed(1)} kg',
                                style: AppTheme.headingSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy').format(entry.date),
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              if (entry.notes?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  entry.notes!,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.mutedText,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Delete button
                        GestureDetector(
                          onTap: () => _showDeleteWeightEntryDialog(entry),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerGradient[0].withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.dangerGradient[0].withOpacity(
                                  0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.dangerGradient[0],
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title, String subtitle) {
    return AppTheme.buildAnimatedCard(
      backgroundColor: AppTheme.cardBackground,
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Enhanced empty state icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: title.toLowerCase().contains('weight')
                      ? AppTheme.progressGradient
                      : AppTheme.infoGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (title.toLowerCase().contains('weight')
                                ? AppTheme.progressGradient[0]
                                : AppTheme.infoGradient[0])
                            .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                title.toLowerCase().contains('weight')
                    ? Icons.monitor_weight_rounded
                    : Icons.bar_chart_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Action button for weight chart
            if (title.toLowerCase().contains('weight'))
              AppTheme.buildGradientButton(
                text: 'Add First Entry',
                icon: Icons.add_rounded,
                gradient: AppTheme.progressGradient,
                borderRadius: 16,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showEnhancedAddWeightDialog();
                },
              ),
            // Info for workout chart
            if (title.toLowerCase().contains('workout'))
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.infoGradient[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.infoGradient[0].withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.infoGradient[0],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Go to Workouts tab to start',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.infoGradient[0],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _calculateStreak() {
    if (workouts.isEmpty) return 0;

    final completedWorkouts = workouts.where((w) => w.endTime != null).toList();
    if (completedWorkouts.isEmpty) return 0;

    completedWorkouts.sort((a, b) => b.endTime!.compareTo(a.endTime!));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final workout in completedWorkouts) {
      final workoutDate = DateTime(
        workout.endTime!.year,
        workout.endTime!.month,
        workout.endTime!.day,
      );
      final checkDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      if (workoutDate.isAtSameMomentAs(checkDate) ||
          workoutDate.isAtSameMomentAs(
            checkDate.subtract(const Duration(days: 1)),
          )) {
        streak++;
        currentDate = workoutDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  void _showAddWeightDialog() {
    final weightController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Weight Entry', style: AppTheme.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryText),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.mutedText),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryGradient[0],
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.monitor_weight,
                  color: AppTheme.secondaryText,
                ),
                filled: true,
                fillColor: AppTheme.cardBackground,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryText),
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                labelStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.mutedText),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryGradient[0],
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(Icons.note, color: AppTheme.secondaryText),
                filled: true,
                fillColor: AppTheme.cardBackground,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
          ),
          AppTheme.buildGradientButton(
            text: 'Add',
            onPressed: () async {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                final entry = WeightEntry(
                  id: _uuid.v4(),
                  weight: weight,
                  date: DateTime.now(),
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );

                await _databaseHelper.insertWeightEntry(entry);

                // Check for achievement unlocks
                final unlockedAchievements = await _achievementService
                    .checkWeightAchievements(entry);

                await _loadData();
                if (mounted) {
                  Navigator.of(context).pop();
                }

                String successMessage = 'Weight entry added successfully';
                if (unlockedAchievements.isNotEmpty) {
                  final achievementNames = unlockedAchievements
                      .map((a) => a.title)
                      .join(', ');
                  successMessage += '! 🏆 Unlocked: $achievementNames';
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            successMessage,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.lightText,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppTheme.successGradient[0],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEnhancedAddWeightDialog() {
    _showAddWeightDialog(); // For now, use the existing dialog
  }

  void _showDeleteWeightEntryDialog(WeightEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.dangerGradient[0].withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.dangerGradient[0],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Entry',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.dangerGradient[0],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this weight entry?',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.mutedText.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight_rounded,
                        color: AppTheme.primaryGradient[0],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.weight.toStringAsFixed(1)} kg',
                        style: AppTheme.headingSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(entry.date),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  if (entry.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      entry.notes!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.mutedText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.dangerGradient[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: AppTheme.dangerGradient[0],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.dangerGradient[0],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppTheme.buildGradientButton(
            text: 'Delete',
            icon: Icons.delete_rounded,
            gradient: AppTheme.dangerGradient,
            borderRadius: 12,
            onPressed: () async {
              try {
                await _databaseHelper.deleteWeightEntry(entry.id);
                await _loadData();

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Weight entry deleted successfully!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      backgroundColor: AppTheme.successGradient[0],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting entry: $e'),
                      backgroundColor: AppTheme.dangerGradient[0],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
