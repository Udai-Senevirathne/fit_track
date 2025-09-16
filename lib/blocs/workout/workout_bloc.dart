import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../data/repositories/workout_repository.dart';
import '../../services/achievement_service.dart';
import 'workout_event.dart';
import 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository _workoutRepository;
  final AchievementService _achievementService = AchievementService();
  late StreamSubscription _workoutSubscription;

  WorkoutBloc(this._workoutRepository) : super(WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<LoadWorkoutById>(_onLoadWorkoutById);
    on<StartWorkout>(_onStartWorkout);
    on<EndWorkout>(_onEndWorkout);
    on<AddWorkout>(_onAddWorkout);
    on<UpdateWorkout>(_onUpdateWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
    on<AddSetToWorkout>(_onAddSetToWorkout);
    on<UpdateWorkoutSet>(_onUpdateWorkoutSet);
    on<DeleteWorkoutSet>(_onDeleteWorkoutSet);
    on<WorkoutsUpdated>(_onWorkoutsUpdated);

    // Start listening to real-time updates
    _startListeningToUpdates();
  }

  void _startListeningToUpdates() {
    _workoutSubscription = _workoutRepository.workoutsStream.listen((workouts) {
      add(WorkoutsUpdated(workouts));
    });
  }

  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workouts = await _workoutRepository.getAllWorkouts();
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError('Failed to load workouts: ${e.toString()}'));
    }
  }

  Future<void> _onLoadWorkoutById(
    LoadWorkoutById event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workout = await _workoutRepository.getWorkoutById(event.workoutId);
      if (workout != null) {
        emit(WorkoutDetailLoaded(workout));
      } else {
        emit(const WorkoutError('Workout not found'));
      }
    } catch (e) {
      emit(WorkoutError('Failed to load workout: ${e.toString()}'));
    }
  }

  Future<void> _onStartWorkout(
    StartWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.addWorkout(event.workout);
      emit(WorkoutInProgress(event.workout));
    } catch (e) {
      emit(WorkoutError('Failed to start workout: ${e.toString()}'));
    }
  }

  Future<void> _onEndWorkout(
    EndWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      final workout = await _workoutRepository.getWorkoutById(event.workoutId);
      if (workout != null) {
        final updatedWorkout = workout.copyWith(endTime: DateTime.now());
        await _workoutRepository.updateWorkout(updatedWorkout);

        // Check for achievement unlocks
        final unlockedAchievements = await _achievementService
            .checkWorkoutAchievements(updatedWorkout);

        String successMessage = 'Workout completed successfully';
        if (unlockedAchievements.isNotEmpty) {
          final achievementNames = unlockedAchievements
              .map((a) => a.title)
              .join(', ');
          successMessage += '! 🏆 Unlocked: $achievementNames';
        }

        emit(WorkoutOperationSuccess(successMessage));
        // Real-time update will be triggered automatically via stream
      } else {
        emit(const WorkoutError('Workout not found'));
      }
    } catch (e) {
      emit(WorkoutError('Failed to end workout: ${e.toString()}'));
    }
  }

  Future<void> _onAddWorkout(
    AddWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.addWorkout(event.workout);
      emit(const WorkoutOperationSuccess('Workout added successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(WorkoutError('Failed to add workout: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateWorkout(
    UpdateWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.updateWorkout(event.workout);
      emit(const WorkoutOperationSuccess('Workout updated successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(WorkoutError('Failed to update workout: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteWorkout(
    DeleteWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.deleteWorkout(event.workoutId);
      emit(const WorkoutOperationSuccess('Workout deleted successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(WorkoutError('Failed to delete workout: ${e.toString()}'));
    }
  }

  Future<void> _onAddSetToWorkout(
    AddSetToWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.addSetToWorkout(event.workoutId, event.set);
      emit(const WorkoutOperationSuccess('Set added successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(WorkoutError('Failed to add set: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateWorkoutSet(
    UpdateWorkoutSet event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.updateWorkoutSet(event.workoutId, event.set);
      emit(const WorkoutOperationSuccess('Set updated successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(WorkoutError('Failed to update set: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteWorkoutSet(
    DeleteWorkoutSet event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _workoutRepository.deleteWorkoutSet(event.setId);
      emit(const WorkoutOperationSuccess('Set deleted successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(WorkoutError('Failed to delete set: ${e.toString()}'));
    }
  }

  void _onWorkoutsUpdated(WorkoutsUpdated event, Emitter<WorkoutState> emit) {
    emit(WorkoutLoaded(event.workouts));
  }

  @override
  Future<void> close() {
    _workoutSubscription.cancel();
    return super.close();
  }
}
