import '../database/database_helper.dart';
import '../../models/exercise.dart';

class ExerciseRepository {
  final DatabaseHelper _databaseHelper;

  ExerciseRepository(this._databaseHelper);

  // Real-time stream for all exercises
  Stream<List<Exercise>> get exercisesStream => _databaseHelper.exercisesStream;

  Future<List<Exercise>> getAllExercises() async {
    return await _databaseHelper.getAllExercises();
  }

  Future<Exercise?> getExerciseById(String id) async {
    return await _databaseHelper.getExerciseById(id);
  }

  Future<void> addExercise(Exercise exercise) async {
    await _databaseHelper.insertExercise(exercise);
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _databaseHelper.updateExercise(exercise);
  }

  Future<void> deleteExercise(String id) async {
    await _databaseHelper.deleteExercise(id);
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    final allExercises = await getAllExercises();
    return allExercises
        .where((exercise) => exercise.muscleGroup == muscleGroup)
        .toList();
  }

  Future<List<Exercise>> getExercisesByCategory(String category) async {
    final allExercises = await getAllExercises();
    return allExercises
        .where((exercise) => exercise.category == category)
        .toList();
  }

  // Real-time stream methods for filtered data
  Stream<List<Exercise>> getExercisesByMuscleGroupStream(String muscleGroup) {
    return exercisesStream.map(
      (exercises) => exercises
          .where((exercise) => exercise.muscleGroup == muscleGroup)
          .toList(),
    );
  }

  Stream<List<Exercise>> getExercisesByCategoryStream(String category) {
    return exercisesStream.map(
      (exercises) =>
          exercises.where((exercise) => exercise.category == category).toList(),
    );
  }
}
