import 'dart:convert';
import '../data/database/database_helper.dart';

class OfflineDataService {
  static final OfflineDataService _instance = OfflineDataService._internal();
  factory OfflineDataService() => _instance;
  OfflineDataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Export all data to JSON string for backup
  Future<String> exportToJson() async {
    try {
      final data = await _dbHelper.exportAllData();
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      print('Export error: $e');
      return '';
    }
  }

  /// Import data from JSON string
  Future<bool> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return await _dbHelper.importData(data);
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }

  /// Get storage usage information
  Future<Map<String, dynamic>> getStorageInfo() async {
    final stats = await _dbHelper.getDatabaseStats();

    return {
      'total_records': stats.values.fold(0, (sum, count) => sum + count),
      'breakdown': stats,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Optimize database (VACUUM)
  Future<void> optimizeDatabase() async {
    final db = await _dbHelper.database;
    await db.execute('VACUUM');
  }

  /// Clean old data beyond retention period
  Future<void> cleanupOldData({int daysToKeep = 365}) async {
    await _dbHelper.cleanupOldData(daysToKeep: daysToKeep);
  }

  /// Get workout statistics for offline insights
  Future<Map<String, dynamic>> getDetailedStats() async {
    final basicStats = await _dbHelper.getWorkoutStats();
    final dbStats = await _dbHelper.getDatabaseStats();
    final storageInfo = await getStorageInfo();

    return {
      'workout_stats': basicStats,
      'database_stats': dbStats,
      'storage_info': storageInfo,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Validate data integrity
  Future<Map<String, bool>> validateDataIntegrity() async {
    final results = <String, bool>{};

    try {
      final db = await _dbHelper.database;

      // Check for orphaned workout sets
      final orphanedSets = await db.rawQuery('''
        SELECT COUNT(*) as count FROM workout_sets ws
        WHERE NOT EXISTS (
          SELECT 1 FROM workouts w WHERE w.id = ws.workoutId
        )
      ''');
      results['no_orphaned_sets'] = (orphanedSets.first['count'] as int) == 0;

      // Check for invalid exercise references
      final invalidExercises = await db.rawQuery('''
        SELECT COUNT(*) as count FROM workout_sets ws
        WHERE NOT EXISTS (
          SELECT 1 FROM exercises e WHERE e.id = ws.exerciseId
        )
      ''');
      results['valid_exercise_refs'] =
          (invalidExercises.first['count'] as int) == 0;

      // Check for future workout dates
      final futureWorkouts = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM workouts
        WHERE startTime > ?
      ''',
        [DateTime.now().millisecondsSinceEpoch],
      );
      results['no_future_workouts'] =
          (futureWorkouts.first['count'] as int) == 0;

      results['overall_integrity'] = results.values.every((valid) => valid);
    } catch (e) {
      print('Integrity check error: $e');
      results['overall_integrity'] = false;
    }

    return results;
  }
}
