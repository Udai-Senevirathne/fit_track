import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../blocs/workout/workout_bloc.dart';
import '../blocs/workout/workout_event.dart';
import '../blocs/workout/workout_state.dart';
import '../blocs/exercise/exercise_bloc.dart';
import '../blocs/exercise/exercise_event.dart';
import '../blocs/exercise/exercise_state.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import 'workout_in_progress_screen.dart';
import '../config/app_theme.dart';

class StartWorkoutScreen extends StatefulWidget {
  const StartWorkoutScreen({super.key});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ExerciseBloc>().add(LoadExercises());
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.workoutGradient[0], AppTheme.backgroundColor],
          ),
        ),
        child: BlocListener<WorkoutBloc, WorkoutState>(
          listener: (context, state) {
            if (state is WorkoutInProgress) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      WorkoutInProgressScreen(workout: state.currentWorkout),
                ),
              );
            } else if (state is WorkoutError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            }
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Modern Large Gradient Header with Curved Bottom
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Stack(
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 200,
                            maxHeight: 240,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppTheme.workoutGradient,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.workoutGradient[0].withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                28,
                                48,
                                28,
                                32,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightText.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: AppTheme.lightText,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Start Workout',
                                            style: AppTheme.headingLarge
                                                .copyWith(
                                                  color: AppTheme.lightText,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Flexible(
                                          child: Text(
                                            'Create and begin your workout session',
                                            style: AppTheme.bodyLarge.copyWith(
                                              color: AppTheme.lightText
                                                  .withValues(alpha: 0.92),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.22,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.fitness_center_rounded,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Workout Details Card
                        AppTheme.buildAnimatedCard(
                          backgroundColor: AppTheme.cardBackground,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: AppTheme.cardDecoration(
                                      gradient: AppTheme.workoutGradient,
                                      borderRadius: 16,
                                    ),
                                    child: const Icon(
                                      Icons.fitness_center_rounded,
                                      color: AppTheme.lightText,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Workout Details',
                                    style: AppTheme.headingSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _nameController,
                                label: 'Workout Name',
                                hint: 'e.g., Push Day, Leg Day, etc.',
                                icon: Icons.label_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _descriptionController,
                                label: 'Description (Optional)',
                                hint: 'Add any notes about this workout...',
                                icon: Icons.description_rounded,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Available Exercises Card
                        SizedBox(
                          height: 400,
                          child: AppTheme.buildAnimatedCard(
                            backgroundColor: AppTheme.cardBackground,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: AppTheme.cardDecoration(
                                        gradient: AppTheme.infoGradient,
                                        borderRadius: 16,
                                      ),
                                      child: const Icon(
                                        Icons.list_rounded,
                                        color: AppTheme.lightText,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Available Exercises',
                                      style: AppTheme.headingSmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: BlocBuilder<ExerciseBloc, ExerciseState>(
                                    builder: (context, state) {
                                      if (state is ExerciseLoading) {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppTheme.primaryBlue,
                                                ),
                                          ),
                                        );
                                      } else if (state is ExerciseLoaded) {
                                        return _buildExerciseList(
                                          state.exercises,
                                        );
                                      } else if (state is ExerciseError) {
                                        return Center(
                                          child: Text(
                                            state.message,
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.secondaryText,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return AppTheme.buildEmptyState(
                                          icon: Icons.fitness_center_rounded,
                                          title: 'No Exercises Available',
                                          message:
                                              'Add exercises to your library to get started',
                                          gradient: AppTheme.infoGradient,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Start Workout Button
                        AppTheme.buildGradientButton(
                          text: 'Start Workout',
                          onPressed: _startWorkout,
                          gradient: AppTheme.workoutGradient,
                          icon: Icons.play_arrow_rounded,
                          height: 60,
                          borderRadius: 20,
                        ),
                        const SizedBox(height: 100), // Extra space for content
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration(
        backgroundColor: AppTheme.backgroundColor,
        borderRadius: AppTheme.radiusM,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: AppTheme.bodyMedium,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.secondaryText,
          ),
          hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.mutedText),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppTheme.spacingM),
        ),
      ),
    );
  }

  Widget _buildExerciseList(List<Exercise> exercises) {
    if (exercises.isEmpty) {
      return AppTheme.buildEmptyState(
        icon: Icons.fitness_center_rounded,
        title: 'No Exercises Available',
        message: 'Add exercises to your library to get started',
        gradient: AppTheme.infoGradient,
      );
    }

    final groupedExercises = <String, List<Exercise>>{};
    for (var exercise in exercises) {
      if (!groupedExercises.containsKey(exercise.muscleGroup)) {
        groupedExercises[exercise.muscleGroup] = [];
      }
      groupedExercises[exercise.muscleGroup]!.add(exercise);
    }

    return ListView(
      children: groupedExercises.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          decoration: AppTheme.cardDecoration(
            backgroundColor: AppTheme.backgroundColor,
            borderRadius: AppTheme.radiusM,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              expansionTileTheme: ExpansionTileThemeData(
                iconColor: AppTheme.primaryBlue,
                collapsedIconColor: AppTheme.secondaryText,
              ),
            ),
            child: ExpansionTile(
              title: Text(
                entry.key,
                style: AppTheme.headingSmall.copyWith(fontSize: 16),
              ),
              children: entry.value.map((exercise) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: AppTheme.cardDecoration(
                    backgroundColor: AppTheme.cardBackground,
                    borderRadius: AppTheme.radiusS,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      exercise.name,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    subtitle: Text(
                      exercise.category,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: AppTheme.cardDecoration(
                        gradient: AppTheme.infoGradient,
                        borderRadius: AppTheme.radiusS,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.lightText,
                        size: 20,
                      ),
                    ),
                    onTap: () {
                      _showExerciseDetails(exercise);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: AppTheme.cardDecoration(
            backgroundColor: AppTheme.cardBackground,
            borderRadius: AppTheme.radiusL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: AppTheme.cardDecoration(
                      gradient: AppTheme.infoGradient,
                      borderRadius: AppTheme.radiusM,
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: AppTheme.lightText,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Text(exercise.name, style: AppTheme.headingSmall),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              _buildDetailRow('Category', exercise.category),
              const SizedBox(height: AppTheme.spacingM),
              _buildDetailRow('Muscle Group', exercise.muscleGroup),
              if (exercise.description != null) ...[
                const SizedBox(height: AppTheme.spacingM),
                _buildDetailRow('Description', exercise.description!),
              ],
              const SizedBox(height: AppTheme.spacingL),
              AppTheme.buildGradientButton(
                text: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                gradient: AppTheme.infoGradient,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: AppTheme.cardDecoration(
        backgroundColor: AppTheme.backgroundColor,
        borderRadius: AppTheme.radiusS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              '$label:',
              style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyMedium,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _startWorkout() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a workout name'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
      return;
    }

    final workout = Workout(
      id: _uuid.v4(),
      name: name,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startTime: DateTime.now(),
      sets: [],
    );

    context.read<WorkoutBloc>().add(StartWorkout(workout));
  }
}
