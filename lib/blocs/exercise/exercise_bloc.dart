import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../data/repositories/exercise_repository.dart';
import 'exercise_event.dart';
import 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseRepository _exerciseRepository;
  late StreamSubscription _exerciseSubscription;

  ExerciseBloc(this._exerciseRepository) : super(ExerciseInitial()) {
    on<LoadExercises>(_onLoadExercises);
    on<LoadExercisesByMuscleGroup>(_onLoadExercisesByMuscleGroup);
    on<LoadExercisesByCategory>(_onLoadExercisesByCategory);
    on<AddExercise>(_onAddExercise);
    on<UpdateExercise>(_onUpdateExercise);
    on<DeleteExercise>(_onDeleteExercise);
    on<ExercisesUpdated>(_onExercisesUpdated);

    // Start listening to real-time updates
    _startListeningToUpdates();
  }

  void _startListeningToUpdates() {
    _exerciseSubscription = _exerciseRepository.exercisesStream.listen((
      exercises,
    ) {
      add(ExercisesUpdated(exercises));
    });
  }

  Future<void> _onLoadExercises(
    LoadExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(ExerciseLoading());
    try {
      final exercises = await _exerciseRepository.getAllExercises();
      emit(ExerciseLoaded(exercises));
    } catch (e) {
      emit(ExerciseError('Failed to load exercises: ${e.toString()}'));
    }
  }

  Future<void> _onLoadExercisesByMuscleGroup(
    LoadExercisesByMuscleGroup event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(ExerciseLoading());
    try {
      final exercises = await _exerciseRepository.getExercisesByMuscleGroup(
        event.muscleGroup,
      );
      emit(ExerciseLoaded(exercises));
    } catch (e) {
      emit(
        ExerciseError(
          'Failed to load exercises by muscle group: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadExercisesByCategory(
    LoadExercisesByCategory event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(ExerciseLoading());
    try {
      final exercises = await _exerciseRepository.getExercisesByCategory(
        event.category,
      );
      emit(ExerciseLoaded(exercises));
    } catch (e) {
      emit(
        ExerciseError('Failed to load exercises by category: ${e.toString()}'),
      );
    }
  }

  Future<void> _onAddExercise(
    AddExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      await _exerciseRepository.addExercise(event.exercise);
      emit(const ExerciseOperationSuccess('Exercise added successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(ExerciseError('Failed to add exercise: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateExercise(
    UpdateExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      await _exerciseRepository.updateExercise(event.exercise);
      emit(const ExerciseOperationSuccess('Exercise updated successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(ExerciseError('Failed to update exercise: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteExercise(
    DeleteExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    try {
      await _exerciseRepository.deleteExercise(event.exerciseId);
      emit(const ExerciseOperationSuccess('Exercise deleted successfully'));
      // Real-time update will be triggered automatically via stream
    } catch (e) {
      emit(ExerciseError('Failed to delete exercise: ${e.toString()}'));
    }
  }

  void _onExercisesUpdated(
    ExercisesUpdated event,
    Emitter<ExerciseState> emit,
  ) {
    emit(ExerciseLoaded(event.exercises));
  }

  @override
  Future<void> close() {
    _exerciseSubscription.cancel();
    return super.close();
  }
}
