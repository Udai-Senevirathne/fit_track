import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/workout/workout_bloc.dart';
import '../blocs/workout/workout_event.dart';
import '../blocs/workout/workout_state.dart';
import '../models/workout.dart';
import 'start_workout_screen.dart';
import 'workout_detail_screen.dart';
import '../config/app_theme.dart';
import '../data/database/database_helper.dart';

class WorkoutFragmentStunning extends StatefulWidget {
  const WorkoutFragmentStunning({super.key});

  @override
  State<WorkoutFragmentStunning> createState() =>
      _WorkoutFragmentStunningState();
}

class _WorkoutFragmentStunningState extends State<WorkoutFragmentStunning>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();

    // Ensure workouts load when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WorkoutBloc>().add(LoadWorkouts());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add safety check for mounted state
    if (!mounted) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WorkoutBloc>().add(LoadWorkouts());
          },
          color: AppTheme.primaryBlue,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Enhanced Quick Start Section
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(child: _buildQuickStartCard()),
              ),

              // Workout Stats Overview
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverToBoxAdapter(child: _buildWorkoutStats()),
              ),

              // Recent Workouts Section Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverToBoxAdapter(child: _buildSectionHeader()),
              ),

              // Workouts List
              BlocBuilder<WorkoutBloc, WorkoutState>(
                builder: (context, state) {
                  print('🔄 Workout State: ${state.runtimeType}');

                  if (state is WorkoutLoading) {
                    print('📥 Loading workouts...');
                    return SliverToBoxAdapter(child: _buildLoadingState());
                  } else if (state is WorkoutLoaded) {
                    print('✅ Workouts loaded: ${state.workouts.length}');
                    if (state.workouts.isEmpty) {
                      print('📝 No workouts found - showing empty state');
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(child: _buildEmptyState()),
                      );
                    }
                    print('📋 Displaying ${state.workouts.length} workouts');
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final workout = state.workouts[index];
                          return AnimatedContainer(
                            duration: Duration(
                              milliseconds: 300 + (index * 50),
                            ),
                            curve: Curves.easeOut,
                            child: _buildWorkoutCard(workout, index),
                          );
                        }, childCount: state.workouts.length),
                      ),
                    );
                  } else if (state is WorkoutError) {
                    print('❌ Workout error: ${state.message}');
                    return SliverToBoxAdapter(
                      child: _buildErrorState(state.message),
                    );
                  }
                  print('⚠️ Unknown workout state');
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.workoutGradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 48,
              color: AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Workouts Yet',
            style: AppTheme.headingLarge.copyWith(color: AppTheme.primaryText),
          ),
          const SizedBox(height: 12),
          Text(
            'Start your fitness journey by creating your first workout!',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.secondaryText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppTheme.buildGradientButton(
            text: 'Create First Workout',
            icon: Icons.add_rounded,
            gradient: AppTheme.workoutGradient,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StartWorkoutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout, int index) {
    final gradients = [
      AppTheme.workoutGradient,
      AppTheme.successGradient,
      AppTheme.warningGradient,
      AppTheme.dangerGradient,
    ];

    final gradient = gradients[index % gradients.length];
    final isCompleted = workout.endTime != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.spacingM),
        border: isCompleted
            ? Border.all(color: AppTheme.accentGreen, width: 2)
            : Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? const Color(0xFF27AE60).withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(workoutId: workout.id),
            ),
          );
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showWorkoutOptionsMenu(workout);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.fitness_center,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.sets.length} exercises',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(workout.startTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showWorkoutOptionsMenu(workout),
                icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildQuickStartCard() {
    return AppTheme.buildAnimatedCard(
      gradient: AppTheme.workoutGradient,
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.lightText.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppTheme.lightText,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to Train?',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.lightText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Start your workout journey now',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.lightText.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Container(
            width: double.infinity,
            decoration: AppTheme.cardDecoration(
              backgroundColor: AppTheme.lightText,
              borderRadius: AppTheme.radiusL,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StartWorkoutScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingS),
                        decoration: AppTheme.cardDecoration(
                          gradient: AppTheme.workoutGradient,
                          borderRadius: AppTheme.radiusM,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppTheme.lightText,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        'Start New Workout',
                        style: AppTheme.headingSmall.copyWith(
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats() {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        int totalWorkouts = 0;
        int completedWorkouts = 0;
        int activeWorkouts = 0;

        if (state is WorkoutLoaded) {
          totalWorkouts = state.workouts.length;
          completedWorkouts = state.workouts
              .where((w) => w.endTime != null)
              .length;
          activeWorkouts = state.workouts
              .where((w) => w.endTime == null)
              .length;
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total',
                totalWorkouts.toString(),
                Icons.fitness_center_rounded,
                const Color(0xFF667eea),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Completed',
                completedWorkouts.toString(),
                Icons.check_circle_rounded,
                const Color(0xFF43e97b),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Active',
                activeWorkouts.toString(),
                Icons.play_circle_rounded,
                const Color(0xFFf093fb),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Workouts',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                'Your fitness journey continues',
                style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF43e97b).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BlocBuilder<WorkoutBloc, WorkoutState>(
            builder: (context, state) {
              final count = state is WorkoutLoaded ? state.workouts.length : 0;
              return Text(
                '$count total',
                style: const TextStyle(
                  color: Color(0xFF43e97b),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.read<WorkoutBloc>().add(LoadWorkouts());
          },
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF43e97b)),
          tooltip: 'Refresh Workouts',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your workouts...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<WorkoutBloc>().add(LoadWorkouts());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkoutOptionsMenu(Workout workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.spacingL),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppTheme.workoutGradient,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
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
                        workout.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      Text(
                        '${workout.sets.length} exercises',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            const Divider(),
            const SizedBox(height: AppTheme.spacingM),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: const Text(
                'Delete Workout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              subtitle: const Text(
                'This action cannot be undone',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteWorkoutDialog(workout);
              },
            ),
            const SizedBox(height: AppTheme.spacingM),
          ],
        ),
      ),
    );
  }

  void _showDeleteWorkoutDialog(Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.spacingM),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Workout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${workout.name}"?',
              style: TextStyle(fontSize: 16, color: AppTheme.primaryText),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: Colors.red.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  const Expanded(
                    child: Text(
                      'This will permanently delete the workout and all its exercise sets. This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
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
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteWorkout(workout);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWorkout(Workout workout) async {
    try {
      HapticFeedback.mediumImpact();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _databaseHelper.deleteWorkout(workout.id);

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Workout "${workout.name}" deleted successfully'),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Failed to delete workout'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
    }
  }
}
