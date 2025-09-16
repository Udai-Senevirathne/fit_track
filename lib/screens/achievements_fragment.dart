import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/database/database_helper.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../config/app_theme.dart';

class AchievementsFragment extends StatefulWidget {
  const AchievementsFragment({super.key});

  @override
  State<AchievementsFragment> createState() => _AchievementsFragmentState();
}

class _AchievementsFragmentState extends State<AchievementsFragment> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AchievementService _achievementService = AchievementService();
  List<Achievement> achievements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      // First recalculate all achievements to ensure they're up to date
      await _achievementService.recalculateAllAchievements();

      final achievementList = await _databaseHelper.getAllAchievements();
      setState(() {
        achievements = achievementList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _recalculateAchievements() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _achievementService.recalculateAllAchievements();
      final achievementList = await _databaseHelper.getAllAchievements();

      setState(() {
        achievements = achievementList;
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.refresh, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Achievements updated!'),
              ],
            ),
            backgroundColor: AppTheme.achievementGradient[0],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating achievements: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
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
          : achievements.isEmpty
          ? _buildEmptyState()
          : _buildAchievementsList(),
    );
  }

  Widget _buildEmptyState() {
    return AppTheme.buildEmptyState(
      icon: Icons.emoji_events_rounded,
      title: 'No Achievements Yet',
      message: 'Complete workouts and reach your goals to unlock achievements!',
    );
  }

  Widget _buildAchievementsList() {
    final unlockedAchievements = achievements
        .where((a) => a.isUnlocked)
        .toList();
    final lockedAchievements = achievements
        .where((a) => !a.isUnlocked)
        .toList();

    return CustomScrollView(
      slivers: [
        // Header with stats
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(AppTheme.spacingL),
            child: AppTheme.buildAnimatedCard(
              backgroundColor: AppTheme.cardBackground,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: AppTheme.cardDecoration(
                      gradient: AppTheme.achievementGradient,
                      borderRadius: AppTheme.radiusM,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppTheme.lightText,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${unlockedAchievements.length}/${achievements.length} Unlocked',
                          style: AppTheme.headingMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          'Keep going to unlock more!',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircularProgressIndicator(
                    value: achievements.isNotEmpty
                        ? unlockedAchievements.length / achievements.length
                        : 0.0,
                    backgroundColor: AppTheme.mutedText.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentOrange,
                    ),
                    strokeWidth: 6,
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _recalculateAchievements();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: AppTheme.cardDecoration(
                        gradient: AppTheme.achievementGradient,
                        borderRadius: AppTheme.radiusS,
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.lightText,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Unlocked achievements
        if (unlockedAchievements.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingL,
                0,
                AppTheme.spacingL,
                AppTheme.spacingM,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: AppTheme.cardDecoration(
                      gradient: AppTheme.successGradient,
                      borderRadius: AppTheme.radiusS,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.lightText,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Text('Unlocked Achievements', style: AppTheme.headingSmall),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildAchievementCard(unlockedAchievements[index], true),
                childCount: unlockedAchievements.length,
              ),
            ),
          ),
        ],

        // Locked achievements
        if (lockedAchievements.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingL,
                AppTheme.spacingXL,
                AppTheme.spacingL,
                AppTheme.spacingM,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: AppTheme.cardDecoration(
                      backgroundColor: AppTheme.mutedText,
                      borderRadius: AppTheme.radiusS,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppTheme.lightText,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Text(
                    'Locked Achievements',
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildAchievementCard(lockedAchievements[index], false),
                childCount: lockedAchievements.length,
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: AppTheme.buildAnimatedCard(
        onTap: isUnlocked
            ? () {
                HapticFeedback.lightImpact();
                _showAchievementDetails(achievement);
              }
            : null,
        gradient: isUnlocked ? AppTheme.achievementGradient : null,
        backgroundColor: isUnlocked ? null : AppTheme.cardBackground,
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: AppTheme.cardDecoration(
                    gradient: isUnlocked
                        ? AppTheme.achievementGradient
                        : [
                            AppTheme.mutedText,
                            AppTheme.mutedText.withValues(alpha: 0.8),
                          ],
                    borderRadius: 32,
                    boxShadow: [],
                  ),
                  child: Icon(
                    _getAchievementIcon(achievement.type),
                    size: 32,
                    color: AppTheme.lightText,
                  ),
                ),
                if (isUnlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: AppTheme.cardDecoration(
                        gradient: AppTheme.successGradient,
                        borderRadius: 12,
                        boxShadow: [],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppTheme.lightText,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppTheme.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: AppTheme.headingSmall.copyWith(
                      color: isUnlocked
                          ? AppTheme.lightText
                          : AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    achievement.description,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isUnlocked
                          ? AppTheme.lightText.withValues(alpha: 0.9)
                          : AppTheme.secondaryText,
                    ),
                  ),
                  if (isUnlocked && achievement.unlockedDate != null) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: AppTheme.cardDecoration(
                        backgroundColor: AppTheme.lightText.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: AppTheme.radiusRound,
                        boxShadow: [],
                      ),
                      child: Text(
                        'Unlocked: ${_formatDate(achievement.unlockedDate!)}',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.lightText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstWorkout:
        return Icons.fitness_center_rounded;
      case AchievementType.consistentWeek:
        return Icons.calendar_today_rounded;
      case AchievementType.consistentMonth:
        return Icons.workspace_premium_rounded;
      case AchievementType.strengthMilestone:
        return Icons.upgrade_rounded;
      case AchievementType.volumeMilestone:
        return Icons.repeat_rounded;
      case AchievementType.workoutCount:
        return Icons.numbers_rounded;
      case AchievementType.weightGoal:
        return Icons.monitor_weight_rounded;
      case AchievementType.custom:
        return Icons.local_fire_department_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: AppTheme.cardDecoration(
                gradient: AppTheme.achievementGradient,
                borderRadius: AppTheme.radiusM,
              ),
              child: Icon(
                _getAchievementIcon(achievement.type),
                color: AppTheme.lightText,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(achievement.title, style: AppTheme.headingSmall),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
            if (achievement.unlockedDate != null) ...[
              const SizedBox(height: AppTheme.spacingL),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: AppTheme.cardDecoration(
                  gradient: AppTheme.successGradient,
                  borderRadius: AppTheme.radiusM,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.celebration_rounded,
                      color: AppTheme.lightText,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Unlocked on ${_formatDate(achievement.unlockedDate!)}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.lightText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (achievement.progress > 0 && achievement.target > 0) ...[
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Progress',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              LinearProgressIndicator(
                value: achievement.progress / achievement.target,
                backgroundColor: AppTheme.mutedText.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.achievementGradient[0],
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '${achievement.progress.toStringAsFixed(0)} / ${achievement.target.toStringAsFixed(0)} ${achievement.unit}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ],
        ),
        actions: [
          AppTheme.buildGradientButton(
            text: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
