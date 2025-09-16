import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../data/database/database_helper.dart';
import '../models/goal.dart';
import '../config/app_theme.dart';

class GoalsFragment extends StatefulWidget {
  const GoalsFragment({super.key});

  @override
  State<GoalsFragment> createState() => _GoalsFragmentState();
}

class _GoalsFragmentState extends State<GoalsFragment> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _uuid = const Uuid();
  List<Goal> goals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final goalList = await _databaseHelper.getAllGoals();
      setState(() {
        goals = goalList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            )
          : goals.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadGoals,
              color: AppTheme.primaryBlue,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  return _buildGoalCard(goals[index]);
                },
              ),
            ),
      floatingActionButton: AppTheme.buildGradientButton(
        text: 'Add Goal',
        icon: Icons.add_rounded,
        gradient: AppTheme.goalGradient,
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddGoalDialog();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppTheme.buildEmptyState(
      icon: Icons.flag_rounded,
      title: 'No Goals Yet',
      message: 'Set your first fitness goal to start tracking your progress!',
      gradient: AppTheme.goalGradient,
      action: AppTheme.buildGradientButton(
        text: 'Create Goal',
        icon: Icons.add_rounded,
        gradient: AppTheme.goalGradient,
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddGoalDialog();
        },
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final isCompleted = goal.isCompleted;
    final progressPercentage = goal.progressPercentage;

    return AppTheme.buildAnimatedCard(
      onTap: () {
        HapticFeedback.lightImpact();
        // You can add navigation to goal details here if needed
      },
      gradient: isCompleted ? AppTheme.successGradient : null,
      backgroundColor: isCompleted ? null : AppTheme.cardBackground,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: AppTheme.cardDecoration(
                  gradient: isCompleted
                      ? AppTheme.successGradient
                      : AppTheme.goalGradient,
                  borderRadius: AppTheme.radiusM,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : _getGoalIcon(goal.type),
                  color: AppTheme.lightText,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppTheme.headingSmall.copyWith(
                        color: isCompleted
                            ? AppTheme.lightText
                            : AppTheme.primaryText,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      goal.description,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isCompleted
                            ? AppTheme.lightText.withOpacity(0.8)
                            : AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: AppTheme.cardDecoration(
                    gradient: AppTheme.successGradient,
                    borderRadius: AppTheme.radiusRound,
                  ),
                  child: Text(
                    'Completed',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: AppTheme.labelMedium.copyWith(
                      color: isCompleted
                          ? AppTheme.lightText
                          : AppTheme.secondaryText,
                    ),
                  ),
                  Text(
                    '${progressPercentage.toStringAsFixed(1)}%',
                    style: AppTheme.labelMedium.copyWith(
                      color: isCompleted
                          ? AppTheme.lightText
                          : AppTheme.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.lightText.withOpacity(0.3)
                      : AppTheme.mutedText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (progressPercentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: AppTheme.cardDecoration(
                      gradient: isCompleted
                          ? AppTheme.successGradient
                          : AppTheme.goalGradient,
                      borderRadius: AppTheme.radiusS,
                      boxShadow: [],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Goal details
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                size: 16,
                color: isCompleted
                    ? AppTheme.lightText.withOpacity(0.8)
                    : AppTheme.secondaryText,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${goal.unit}',
                style: AppTheme.bodySmall.copyWith(
                  color: isCompleted
                      ? AppTheme.lightText.withOpacity(0.8)
                      : AppTheme.secondaryText,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: isCompleted
                    ? AppTheme.lightText.withOpacity(0.8)
                    : AppTheme.secondaryText,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                DateFormat('MMM dd, yyyy').format(goal.targetDate),
                style: AppTheme.bodySmall.copyWith(
                  color: isCompleted
                      ? AppTheme.lightText.withOpacity(0.8)
                      : AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(GoalType type) {
    switch (type) {
      case GoalType.weightLoss:
        return Icons.trending_down;
      case GoalType.weightGain:
        return Icons.trending_up;
      case GoalType.strengthGain:
        return Icons.fitness_center;
      case GoalType.workoutFrequency:
        return Icons.timer;
      case GoalType.custom:
        return Icons.flag;
    }
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();
    final unitController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    GoalType selectedType = GoalType.weightLoss;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add New Goal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Goal Title',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFffa726)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFffa726)),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalType>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Goal Type',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFffa726)),
                    ),
                  ),
                  items: GoalType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getGoalTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: targetController,
                        decoration: InputDecoration(
                          labelText: 'Target Value',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFffa726),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFffa726),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFffa726),
                  ),
                  title: Text(
                    'Target Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () => _addGoal(
                titleController.text,
                descriptionController.text,
                selectedType,
                double.tryParse(targetController.text) ?? 0,
                unitController.text,
                selectedDate,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFffa726),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalTypeName(GoalType type) {
    switch (type) {
      case GoalType.weightLoss:
        return 'Weight Loss';
      case GoalType.weightGain:
        return 'Weight Gain';
      case GoalType.strengthGain:
        return 'Strength Gain';
      case GoalType.workoutFrequency:
        return 'Workout Frequency';
      case GoalType.custom:
        return 'Custom';
    }
  }

  Future<void> _addGoal(
    String title,
    String description,
    GoalType type,
    double target,
    String unit,
    DateTime targetDate,
  ) async {
    if (title.isEmpty || target <= 0 || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final goal = Goal(
      id: _uuid.v4(),
      title: title,
      description: description,
      type: type,
      status: GoalStatus.active,
      targetValue: target,
      currentValue: 0,
      unit: unit,
      startDate: DateTime.now(),
      targetDate: targetDate,
    );

    try {
      await _databaseHelper.insertGoal(goal);
      if (mounted) {
        Navigator.pop(context);
        _loadGoals();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal added successfully!'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding goal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
