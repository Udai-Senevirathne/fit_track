import 'package:equatable/equatable.dart';
import '../../models/workout.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<Workout> workouts;

  const WorkoutLoaded(this.workouts);

  @override
  List<Object?> get props => [workouts];
}

class WorkoutDetailLoaded extends WorkoutState {
  final Workout workout;

  const WorkoutDetailLoaded(this.workout);

  @override
  List<Object?> get props => [workout];
}

class WorkoutInProgress extends WorkoutState {
  final Workout currentWorkout;

  const WorkoutInProgress(this.currentWorkout);

  @override
  List<Object?> get props => [currentWorkout];
}

class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}

class WorkoutOperationSuccess extends WorkoutState {
  final String message;

  const WorkoutOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
