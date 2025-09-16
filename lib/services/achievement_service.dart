import 'dart:async';
import '../data/database/database_helper.dart';
import '../models/achievement.dart';
import '../models/workout.dart';
import '../models/weight_entry.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Check and update achievements when a workout is completed
  Future<List<Achievement>> checkWorkoutAchievements(
    Workout completedWorkout,
  ) async {
    final unlockedAchievements = <Achievement>[];

    try {
      final allAchievements = await _dbHelper.getAllAchievements();
      final lockedAchievements = allAchievements
          .where((a) => !a.isUnlocked)
          .toList();

      for (final achievement in lockedAchievements) {
        Achievement? updatedAchievement;

        switch (achievement.type) {
          case AchievementType.firstWorkout:
            updatedAchievement = await _checkFirstWorkout(achievement);
            break;

          case AchievementType.workoutCount:
            updatedAchievement = await _checkWorkoutCount(achievement);
            break;

          case AchievementType.consistentWeek:
            updatedAchievement = await _checkConsistentWeek(achievement);
            break;

          case AchievementType.strengthMilestone:
            updatedAchievement = await _checkStrengthMilestone(
              achievement,
              completedWorkout,
            );
            break;

          default:
            // Skip achievements that don't relate to workout completion
            break;
        }

        if (updatedAchievement != null) {
          await _dbHelper.updateAchievement(updatedAchievement);
          if (updatedAchievement.isUnlocked && !achievement.isUnlocked) {
            unlockedAchievements.add(updatedAchievement);
          }
        }
      }
    } catch (e) {
      print('Error checking workout achievements: $e');
    }

    return unlockedAchievements;
  }

  /// Check and update achievements when weight is logged
  Future<List<Achievement>> checkWeightAchievements(
    WeightEntry weightEntry,
  ) async {
    final unlockedAchievements = <Achievement>[];

    try {
      final allAchievements = await _dbHelper.getAllAchievements();
      final lockedAchievements = allAchievements
          .where((a) => !a.isUnlocked && a.type == AchievementType.weightGoal)
          .toList();

      for (final achievement in lockedAchievements) {
        final updatedAchievement = await _checkWeightGoal(
          achievement,
          weightEntry,
        );

        if (updatedAchievement != null) {
          await _dbHelper.updateAchievement(updatedAchievement);
          if (updatedAchievement.isUnlocked && !achievement.isUnlocked) {
            unlockedAchievements.add(updatedAchievement);
          }
        }
      }
    } catch (e) {
      print('Error checking weight achievements: $e');
    }

    return unlockedAchievements;
  }

  /// Check first workout achievement
  Future<Achievement?> _checkFirstWorkout(Achievement achievement) async {
    final workouts = await _dbHelper.getAllWorkouts();
    final completedWorkouts = workouts.where((w) => w.endTime != null).length;

    if (completedWorkouts >= 1) {
      return achievement.copyWith(
        isUnlocked: true,
        unlockedDate: DateTime.now(),
        progress: 1.0,
      );
    }

    return achievement.copyWith(progress: completedWorkouts.toDouble());
  }

  /// Check workout count achievements (10, 50, etc.)
  Future<Achievement?> _checkWorkoutCount(Achievement achievement) async {
    final workouts = await _dbHelper.getAllWorkouts();
    final completedWorkouts = workouts.where((w) => w.endTime != null).length;

    final progress = completedWorkouts.toDouble();
    final isUnlocked = progress >= achievement.target;

    return achievement.copyWith(
      progress: progress,
      isUnlocked: isUnlocked,
      unlockedDate: isUnlocked ? DateTime.now() : null,
    );
  }

  /// Check consistent week achievement (7 workouts in 7 days)
  Future<Achievement?> _checkConsistentWeek(Achievement achievement) async {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final workouts = await _dbHelper.getWorkoutsByDateRange(oneWeekAgo, now);
    final completedWorkouts = workouts.where((w) => w.endTime != null).length;

    final progress = completedWorkouts.toDouble();
    final isUnlocked = progress >= achievement.target;

    return achievement.copyWith(
      progress: progress,
      isUnlocked: isUnlocked,
      unlockedDate: isUnlocked ? DateTime.now() : null,
    );
  }

  /// Check strength milestone achievement (total weight lifted in one workout)
  Future<Achievement?> _checkStrengthMilestone(
    Achievement achievement,
    Workout workout,
  ) async {
    final sets = await _dbHelper.getWorkoutSets(workout.id);
    final totalWeight = sets.fold<double>(
      0.0,
      (sum, set) => sum + (set.weight * set.reps),
    );

    final progress = totalWeight;
    final isUnlocked = progress >= achievement.target;

    return achievement.copyWith(
      progress: progress,
      isUnlocked: isUnlocked,
      unlockedDate: isUnlocked ? DateTime.now() : null,
    );
  }

  /// Check weight goal achievements
  Future<Achievement?> _checkWeightGoal(
    Achievement achievement,
    WeightEntry weightEntry,
  ) async {
    final allEntries = await _dbHelper.getAllWeightEntries();

    // Handle different types of weight goals
    if (achievement.id == 'weight_consistency') {
      // Track number of weight entries
      final progress = allEntries.length.toDouble();
      final isUnlocked = progress >= achievement.target;

      return achievement.copyWith(
        progress: progress,
        isUnlocked: isUnlocked,
        unlockedDate: isUnlocked && !achievement.isUnlocked
            ? DateTime.now()
            : achievement.unlockedDate,
      );
    } else if (achievement.id == 'weight_loss_5kg') {
      // Track weight change (loss or gain)
      if (allEntries.length < 2) return achievement.copyWith(progress: 0.0);

      // Sort by date to get first and latest entries
      allEntries.sort((a, b) => a.date.compareTo(b.date));
      final firstEntry = allEntries.first;
      final latestEntry = allEntries.last;

      final weightChange = (latestEntry.weight - firstEntry.weight).abs();
      final progress = weightChange;
      final isUnlocked = progress >= achievement.target;

      return achievement.copyWith(
        progress: progress,
        isUnlocked: isUnlocked,
        unlockedDate: isUnlocked && !achievement.isUnlocked
            ? DateTime.now()
            : achievement.unlockedDate,
      );
    }

    return null;
  }

  /// Force recalculate all achievement progress
  Future<void> recalculateAllAchievements() async {
    try {
      final allAchievements = await _dbHelper.getAllAchievements();

      for (final achievement in allAchievements) {
        Achievement? updatedAchievement;

        switch (achievement.type) {
          case AchievementType.firstWorkout:
            updatedAchievement = await _checkFirstWorkout(achievement);
            break;

          case AchievementType.workoutCount:
            updatedAchievement = await _checkWorkoutCount(achievement);
            break;

          case AchievementType.consistentWeek:
            updatedAchievement = await _checkConsistentWeek(achievement);
            break;

          case AchievementType.strengthMilestone:
            // For strength milestone, we need to check the best workout
            updatedAchievement = await _checkBestStrengthMilestone(achievement);
            break;

          default:
            continue;
        }

        if (updatedAchievement != null) {
          await _dbHelper.updateAchievement(updatedAchievement);
        }
      }
    } catch (e) {
      print('Error recalculating achievements: $e');
    }
  }

  /// Check best strength milestone across all workouts
  Future<Achievement?> _checkBestStrengthMilestone(
    Achievement achievement,
  ) async {
    final workouts = await _dbHelper.getAllWorkouts();
    double maxWeight = 0.0;

    for (final workout in workouts.where((w) => w.endTime != null)) {
      final sets = await _dbHelper.getWorkoutSets(workout.id);
      final totalWeight = sets.fold<double>(
        0.0,
        (sum, set) => sum + (set.weight * set.reps),
      );
      if (totalWeight > maxWeight) {
        maxWeight = totalWeight;
      }
    }

    final progress = maxWeight;
    final isUnlocked = progress >= achievement.target;

    return achievement.copyWith(
      progress: progress,
      isUnlocked: isUnlocked,
      unlockedDate: isUnlocked && !achievement.isUnlocked
          ? DateTime.now()
          : achievement.unlockedDate,
    );
  }

  /// Get achievement progress summary
  Future<Map<String, dynamic>> getAchievementSummary() async {
    final achievements = await _dbHelper.getAllAchievements();
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final total = achievements.length;
    final percentage = total > 0 ? (unlocked / total * 100) : 0.0;

    return {
      'unlocked': unlocked,
      'total': total,
      'percentage': percentage,
      'recent_unlocks': achievements
          .where((a) => a.isUnlocked && a.unlockedDate != null)
          .where(
            (a) => a.unlockedDate!.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
          )
          .length,
    };
  }
}
