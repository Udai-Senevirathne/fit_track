import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'workout_fragment_stunning.dart';
import 'progress_fragment.dart';
import 'goals_fragment.dart';
import 'achievements_fragment.dart';
import 'workout_in_progress_screen.dart';
import '../config/app_theme.dart';
import '../data/database/database_helper.dart';
import '../models/workout.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Workout? _ongoingWorkout;
  late StreamSubscription<List<Workout>> _workoutSubscription;

  final List<Widget> _pages = [
    const WorkoutFragmentStunning(),
    const ProgressFragment(),
    const GoalsFragment(),
    const AchievementsFragment(),
  ];

  final List<String> _titles = [
    'Workouts',
    'Progress',
    'Goals',
    'Achievements',
  ];

  final List<IconData> _icons = [
    Icons.fitness_center_rounded,
    Icons.analytics_rounded,
    Icons.flag_rounded,
    Icons.emoji_events_rounded,
  ];

  final List<List<Color>> _gradients = [
    AppTheme.workoutGradient,
    AppTheme.progressGradient,
    AppTheme.goalGradient,
    AppTheme.achievementGradient,
  ];

  @override
  void initState() {
    super.initState();
    _checkForOngoingWorkout();
  }

  @override
  void dispose() {
    _workoutSubscription.cancel();
    super.dispose();
  }

  void _checkForOngoingWorkout() {
    print('🔍 Checking for ongoing workouts...');
    _workoutSubscription = _databaseHelper.workoutsStream.listen((workouts) {
      print('📋 Received ${workouts.length} workouts from stream');
      final ongoing = workouts.where((w) => w.endTime == null).firstOrNull;
      print('🏃‍♂️ Ongoing workout found: ${ongoing?.name ?? 'None'}');
      if (mounted) {
        setState(() {
          _ongoingWorkout = ongoing;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Clean modern background
      body: Column(
        children: [
          // Ultra-Modern Dramatic Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.fireGradient, // Using new fire gradient
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.fireGradient[0].withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _icons[_currentIndex],
                                color: AppTheme.lightText,
                                size: 28,
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              Text(
                                _titles[_currentIndex],
                                style: AppTheme.headingMedium.copyWith(
                                  color: AppTheme.lightText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(
                            '� Your Fitness Revolution Starts Here! �',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.lightText.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.lightText.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: AppTheme.lightText,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Ongoing Workout Banner
          if (_ongoingWorkout != null) _buildOngoingWorkoutBanner(),

          // Page Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.spacingXL),
                  topRight: Radius.circular(AppTheme.spacingXL),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.spacingXL),
                  topRight: Radius.circular(AppTheme.spacingXL),
                ),
                child: IndexedStack(index: _currentIndex, children: _pages),
              ),
            ),
          ),
        ],
      ),

      // Modern Bottom Navigation
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              HapticFeedback.lightImpact();
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: _gradients[_currentIndex][0],
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: List.generate(_titles.length, (index) {
              return BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: _currentIndex == index
                      ? BoxDecoration(
                          gradient: LinearGradient(colors: _gradients[index]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _gradients[index][0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    _icons[index],
                    size: 24,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.grey[400],
                  ),
                ),
                label: _titles[index],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildOngoingWorkoutBanner() {
    if (_ongoingWorkout == null) return const SizedBox.shrink();

    final workout = _ongoingWorkout!;
    final duration = DateTime.now().difference(workout.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutInProgressScreen(workout: workout),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.radio_button_checked,
                            color: Colors.greenAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'WORKOUT IN PROGRESS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${hours}h ${minutes}m elapsed • ${workout.sets.length} exercises',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
