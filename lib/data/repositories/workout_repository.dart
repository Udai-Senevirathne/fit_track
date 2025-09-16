import '../database/database_helper.dart';
import '../../models/workout.dart';
import '../../models/workout_set.dart';

class WorkoutRepository {
  final DatabaseHelper _databaseHelper;

  WorkoutRepository(this._databaseHelper);

  // Real-time stream for all workouts
  Stream<List<Workout>> get workoutsStream => _databaseHelper.workoutsStream;

  Future<List<Workout>> getAllWorkouts() async {
    return await _databaseHelper.getAllWorkouts();
  }

  Future<Workout?> getWorkoutById(String id) async {
    return await _databaseHelper.getWorkoutById(id);
  }

  Future<void> addWorkout(Workout workout) async {
    await _databaseHelper.insertWorkout(workout);
  }

  Future<void> updateWorkout(Workout workout) async {
    await _databaseHelper.updateWorkout(workout);
  }

  Future<void> deleteWorkout(String id) async {
    await _databaseHelper.deleteWorkout(id);
  }

  Future<void> addSetToWorkout(String workoutId, WorkoutSet set) async {
    await _databaseHelper.insertWorkoutSet(set, workoutId);
  }

  Future<void> updateWorkoutSet(String workoutId, WorkoutSet set) async {
    await _databaseHelper.updateWorkoutSet(set, workoutId);
  }

  Future<void> deleteWorkoutSet(String setId) async {
    await _databaseHelper.deleteWorkoutSet(setId);
  }

  Future<List<WorkoutSet>> getWorkoutSets(String workoutId) async {
    return await _databaseHelper.getWorkoutSets(workoutId);
  }

  Future<List<Workout>> getRecentWorkouts(int limit) async {
    final allWorkouts = await getAllWorkouts();
    return allWorkouts.take(limit).toList();
  }

  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allWorkouts = await getAllWorkouts();
    return allWorkouts
        .where(
          (workout) =>
              workout.startTime.isAfter(start) &&
              workout.startTime.isBefore(end),
        )
        .toList();
  }

  // Real-time stream methods for filtered data
  Stream<List<Workout>> getRecentWorkoutsStream(int limit) {
    return workoutsStream.map((workouts) => workouts.take(limit).toList());
  }

  Stream<List<Workout>> getWorkoutsByDateRangeStream(
    DateTime start,
    DateTime end,
  ) {
    return workoutsStream.map(
      (workouts) => workouts
          .where(
            (workout) =>
                workout.startTime.isAfter(start) &&
                workout.startTime.isBefore(end),
          )
          .toList(),
    );
  }
}
