import 'package:equatable/equatable.dart';
import '../../models/exercise.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExercises extends ExerciseEvent {}

class LoadExercisesByMuscleGroup extends ExerciseEvent {
  final String muscleGroup;

  const LoadExercisesByMuscleGroup(this.muscleGroup);

  @override
  List<Object?> get props => [muscleGroup];
}

class LoadExercisesByCategory extends ExerciseEvent {
  final String category;

  const LoadExercisesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class AddExercise extends ExerciseEvent {
  final Exercise exercise;

  const AddExercise(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class UpdateExercise extends ExerciseEvent {
  final Exercise exercise;

  const UpdateExercise(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class DeleteExercise extends ExerciseEvent {
  final String exerciseId;

  const DeleteExercise(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}

class ExercisesUpdated extends ExerciseEvent {
  final List<Exercise> exercises;

  const ExercisesUpdated(this.exercises);

  @override
  List<Object?> get props => [exercises];
}
