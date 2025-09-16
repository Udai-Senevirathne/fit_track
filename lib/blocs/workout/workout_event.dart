import 'package:equatable/equatable.dart';
import '../../models/workout.dart';
import '../../models/workout_set.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkouts extends WorkoutEvent {}

class LoadWorkoutById extends WorkoutEvent {
  final String workoutId;

  const LoadWorkoutById(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class StartWorkout extends WorkoutEvent {
  final Workout workout;

  const StartWorkout(this.workout);

  @override
  List<Object?> get props => [workout];
}

class EndWorkout extends WorkoutEvent {
  final String workoutId;

  const EndWorkout(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class AddWorkout extends WorkoutEvent {
  final Workout workout;

  const AddWorkout(this.workout);

  @override
  List<Object?> get props => [workout];
}

class UpdateWorkout extends WorkoutEvent {
  final Workout workout;

  const UpdateWorkout(this.workout);

  @override
  List<Object?> get props => [workout];
}

class DeleteWorkout extends WorkoutEvent {
  final String workoutId;

  const DeleteWorkout(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class AddSetToWorkout extends WorkoutEvent {
  final String workoutId;
  final WorkoutSet set;

  const AddSetToWorkout(this.workoutId, this.set);

  @override
  List<Object?> get props => [workoutId, set];
}

class UpdateWorkoutSet extends WorkoutEvent {
  final String workoutId;
  final WorkoutSet set;

  const UpdateWorkoutSet(this.workoutId, this.set);

  @override
  List<Object?> get props => [workoutId, set];
}

class DeleteWorkoutSet extends WorkoutEvent {
  final String setId;

  const DeleteWorkoutSet(this.setId);

  @override
  List<Object?> get props => [setId];
}

class WorkoutsUpdated extends WorkoutEvent {
  final List<Workout> workouts;

  const WorkoutsUpdated(this.workouts);

  @override
  List<Object?> get props => [workouts];
}
