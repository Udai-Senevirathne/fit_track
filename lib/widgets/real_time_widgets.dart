import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/database/database_helper.dart';
import '../models/workout.dart';
import '../models/goal.dart';

class RealTimeWorkoutWidget extends StatelessWidget {
  const RealTimeWorkoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseHelper = context.read<DatabaseHelper>();

    return StreamBuilder<List<Workout>>(
      stream: databaseHelper.workoutsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No workouts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final workouts = snapshot.data!;

        return ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  workout.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Started: ${workout.startTime.toString().split('.')[0]}',
                ),
                trailing: workout.endTime != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.timer, color: Colors.orange),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: workout.endTime != null
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: workout.endTime != null
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class RealTimeGoalsWidget extends StatelessWidget {
  const RealTimeGoalsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseHelper = context.read<DatabaseHelper>();

    return StreamBuilder<List<Goal>>(
      stream: databaseHelper.goalsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No goals set yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final goals = snapshot.data!;

        return ListView.builder(
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final progress = (goal.currentValue / goal.targetValue * 100).clamp(
              0.0,
              100.0,
            );
            final isCompleted = goal.status == GoalStatus.completed;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green : Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCompleted ? 'Completed' : 'Active',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (goal.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        goal.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Progress: ${progress.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${goal.unit}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.green : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class RealTimeStatsWidget extends StatelessWidget {
  const RealTimeStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseHelper = context.read<DatabaseHelper>();

    return StreamBuilder<List<Workout>>(
      stream: databaseHelper.workoutsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No statistics available'));
        }

        final workouts = snapshot.data!;
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 1);
        final thisMonthWorkouts = workouts
            .where((w) => w.startTime.isAfter(thisMonth))
            .length;
        final totalWorkouts = workouts.length;

        // Calculate average duration
        final completedWorkouts = workouts.where((w) => w.endTime != null);
        double avgDurationMinutes = 0.0;
        if (completedWorkouts.isNotEmpty) {
          final totalMinutes = completedWorkouts
              .map((w) => w.endTime!.difference(w.startTime).inMinutes)
              .reduce((a, b) => a + b);
          avgDurationMinutes = totalMinutes / completedWorkouts.length;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'This Month',
                      value: thisMonthWorkouts.toString(),
                      icon: Icons.calendar_month,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Workouts',
                      value: totalWorkouts.toString(),
                      icon: Icons.fitness_center,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: 'Average Duration',
                value: '${avgDurationMinutes.toStringAsFixed(1)} min',
                icon: Icons.timer,
                color: Colors.orange,
                width: double.infinity,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
