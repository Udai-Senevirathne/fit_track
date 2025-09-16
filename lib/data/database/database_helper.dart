import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../../models/exercise.dart';
import '../../models/workout.dart';
import '../../models/workout_set.dart';
import '../../models/weight_entry.dart';
import '../../models/goal.dart';
import '../../models/achievement.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Stream controllers for real-time updates
  final _exercisesController = StreamController<List<Exercise>>.broadcast();
  final _workoutsController = StreamController<List<Workout>>.broadcast();
  final _weightEntriesController =
      StreamController<List<WeightEntry>>.broadcast();
  final _goalsController = StreamController<List<Goal>>.broadcast();
  final _achievementsController =
      StreamController<List<Achievement>>.broadcast();

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  // Real-time streams - these will emit data whenever something changes
  Stream<List<Exercise>> get exercisesStream => _exercisesController.stream;
  Stream<List<Workout>> get workoutsStream => _workoutsController.stream;
  Stream<List<WeightEntry>> get weightEntriesStream =>
      _weightEntriesController.stream;
  Stream<List<Goal>> get goalsStream => _goalsController.stream;
  Stream<List<Achievement>> get achievementsStream =>
      _achievementsController.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create exercises table
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        category TEXT NOT NULL CHECK(category IN ('Strength', 'Cardio', 'Flexibility', 'Bodyweight')),
        muscleGroup TEXT NOT NULL CHECK(muscleGroup IN ('Chest', 'Back', 'Legs', 'Arms', 'Shoulders', 'Core', 'Full Body')),
        createdAt INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create workouts table
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        startTime INTEGER NOT NULL,
        endTime INTEGER
      )
    ''');

    // Create workout_sets table
    await db.execute('''
      CREATE TABLE workout_sets (
        id TEXT PRIMARY KEY,
        workoutId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        restTime INTEGER,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (workoutId) REFERENCES workouts (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // Create weight_entries table
    await db.execute('''
      CREATE TABLE weight_entries (
        id TEXT PRIMARY KEY,
        weight REAL NOT NULL,
        date INTEGER NOT NULL,
        note TEXT
      )
    ''');

    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        targetValue REAL NOT NULL,
        currentValue REAL NOT NULL,
        unit TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        targetDate INTEGER NOT NULL,
        completedDate INTEGER
      )
    ''');

    // Create achievements table
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        iconName TEXT NOT NULL,
        target REAL NOT NULL,
        progress REAL NOT NULL,
        unit TEXT NOT NULL,
        isUnlocked INTEGER NOT NULL,
        unlockedDate INTEGER
      )
    ''');

    // Insert default data
    await _insertDefaultExercises(db);
    await _insertDefaultAchievements(db);

    // Create indexes for better performance
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    // Index for workout queries by date
    await db.execute(
      'CREATE INDEX idx_workouts_start_time ON workouts(startTime)',
    );

    // Index for workout sets by workout
    await db.execute(
      'CREATE INDEX idx_workout_sets_workout_id ON workout_sets(workoutId)',
    );

    // Index for weight entries by date
    await db.execute(
      'CREATE INDEX idx_weight_entries_date ON weight_entries(date)',
    );

    // Index for goals by status and date
    await db.execute('CREATE INDEX idx_goals_status ON goals(status)');
    await db.execute('CREATE INDEX idx_goals_target_date ON goals(targetDate)');

    // Index for achievements by unlock status
    await db.execute(
      'CREATE INDEX idx_achievements_unlocked ON achievements(isUnlocked)',
    );
  }

  Future<void> _insertDefaultExercises(Database db) async {
    final defaultExercises = [
      {
        'id': 'bench_press',
        'name': 'Bench Press',
        'description': 'Classic chest exercise',
        'category': 'Strength',
        'muscleGroup': 'Chest',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'squat',
        'name': 'Squat',
        'description': 'Fundamental leg exercise',
        'category': 'Strength',
        'muscleGroup': 'Legs',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'deadlift',
        'name': 'Deadlift',
        'description': 'Full body compound movement',
        'category': 'Strength',
        'muscleGroup': 'Back',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'pull_up',
        'name': 'Pull Up',
        'description': 'Upper body pulling exercise',
        'category': 'Bodyweight',
        'muscleGroup': 'Back',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'push_up',
        'name': 'Push Up',
        'description': 'Classic bodyweight exercise',
        'category': 'Bodyweight',
        'muscleGroup': 'Chest',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (var exercise in defaultExercises) {
      await db.insert('exercises', exercise);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for version 2
      await _createNewTables(db);
    }
    if (oldVersion < 3) {
      // Force create all tables for version 3
      await _createAllTablesForUpgrade(db);
    }
  }

  Future<void> _createAllTablesForUpgrade(Database db) async {
    // Check and create weight_entries table if it doesn't exist
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='weight_entries'",
    );
    if (result.isEmpty) {
      await db.execute('''
        CREATE TABLE weight_entries (
          id TEXT PRIMARY KEY,
          weight REAL NOT NULL,
          date INTEGER NOT NULL,
          note TEXT
        )
      ''');
    }

    // Check and create goals table if it doesn't exist
    result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='goals'",
    );
    if (result.isEmpty) {
      await db.execute('''
        CREATE TABLE goals (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          targetValue REAL NOT NULL,
          currentValue REAL NOT NULL,
          unit TEXT NOT NULL,
          startDate INTEGER NOT NULL,
          targetDate INTEGER NOT NULL,
          completedDate INTEGER
        )
      ''');
    }

    // Check and create achievements table if it doesn't exist
    result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='achievements'",
    );
    if (result.isEmpty) {
      await db.execute('''
        CREATE TABLE achievements (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL,
          iconName TEXT NOT NULL,
          target REAL NOT NULL,
          progress REAL NOT NULL,
          unit TEXT NOT NULL,
          isUnlocked INTEGER NOT NULL,
          unlockedDate INTEGER
        )
      ''');

      // Insert default achievements
      await _insertDefaultAchievements(db);
    }
  }

  Future<void> _createNewTables(Database db) async {
    // Create weight_entries table
    await db.execute('''
      CREATE TABLE weight_entries (
        id TEXT PRIMARY KEY,
        weight REAL NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        targetValue REAL NOT NULL,
        currentValue REAL NOT NULL,
        unit TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        targetDate INTEGER NOT NULL,
        completedDate INTEGER
      )
    ''');

    // Create achievements table
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        iconName TEXT NOT NULL,
        isUnlocked INTEGER NOT NULL,
        unlockedDate INTEGER,
        progress REAL NOT NULL,
        target REAL NOT NULL,
        unit TEXT NOT NULL
      )
    ''');

    // Insert default achievements
    await _insertDefaultAchievements(db);
  }

  Future<void> _insertDefaultAchievements(Database db) async {
    final defaultAchievements = [
      {
        'id': 'first_workout',
        'title': 'First Steps',
        'description': 'Complete your first workout',
        'type': 'firstWorkout',
        'iconName': 'fitness_center',
        'isUnlocked': 0,
        'unlockedDate': null,
        'progress': 0.0,
        'target': 1.0,
        'unit': 'workout',
      },
      {
        'id': 'consistent_week',
        'title': 'Week Warrior',
        'description': 'Complete 7 workouts in a week',
        'type': 'consistentWeek',
        'iconName': 'calendar_today',
        'isUnlocked': 0,
        'unlockedDate': null,
        'progress': 0.0,
        'target': 7.0,
        'unit': 'workouts',
      },
      {
        'id': 'strength_milestone',
        'title': 'Iron Lifter',
        'description': 'Lift a total of 1000kg in a single workout',
        'type': 'strengthMilestone',
        'iconName': 'trending_up',
        'isUnlocked': 0,
        'unlockedDate': null,
        'progress': 0.0,
        'target': 1000.0,
        'unit': 'kg',
      },
      {
        'id': 'workout_count_10',
        'title': 'Dedicated',
        'description': 'Complete 10 workouts',
        'type': 'workoutCount',
        'iconName': 'star',
        'isUnlocked': 0,
        'unlockedDate': null,
        'progress': 0.0,
        'target': 10.0,
        'unit': 'workouts',
      },
      {
        'id': 'workout_count_50',
        'title': 'Committed',
        'description': 'Complete 50 workouts',
        'type': 'workoutCount',
        'iconName': 'emoji_events',
        'isUnlocked': 0,
        'unlockedDate': null,
        'progress': 0.0,
        'target': 50.0,
        'unit': 'workouts',
      },
      {
        'id': 'weight_loss_5kg',
        'title': 'Weight Warrior',
        'description': 'Lose or gain 5kg from your starting weight',
        'type': 'weightGoal',
        'iconName': 'monitor_weight',
        'isUnlocked': 0,
        'unlockedDate': null,
        'progress': 0.0,
        'target': 5.0,
        'unit': 'kg',
      },
      {
        'id': 'weight_consistency',
        'title': 'Tracker Pro',
        'description': 'Log your weight 10 times',
        'type': 'weightGoal',
        'iconName': 'track_changes',
        'isUnlocked': 0,
        'unlockedDate': null,
        'progress': 0.0,
        'target': 10.0,
        'unit': 'entries',
      },
    ];

    for (var achievement in defaultAchievements) {
      await db.insert('achievements', achievement);
    }
  }

  // Exercise CRUD operations with real-time updates
  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final maps = await db.query('exercises', orderBy: 'name ASC');
    final exercises = maps.map((map) => Exercise.fromMap(map)).toList();

    // Emit to stream for real-time updates
    _exercisesController.add(exercises);

    return exercises;
  }

  Future<Exercise?> getExerciseById(String id) async {
    final db = await database;
    final maps = await db.query('exercises', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertExercise(Exercise exercise) async {
    final db = await database;
    await db.insert('exercises', exercise.toMap());

    // Trigger real-time update
    await getAllExercises();
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await database;
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );

    // Trigger real-time update
    await getAllExercises();
  }

  Future<void> deleteExercise(String id) async {
    final db = await database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);

    // Trigger real-time update
    await getAllExercises();
  }

  // Workout CRUD operations with real-time updates
  Future<List<Workout>> getAllWorkouts() async {
    final db = await database;
    final maps = await db.query('workouts', orderBy: 'startTime DESC');

    List<Workout> workouts = [];
    for (var map in maps) {
      final workout = Workout.fromMap(map);
      final sets = await getWorkoutSets(workout.id);
      workouts.add(workout.copyWith(sets: sets));
    }

    // Emit to stream for real-time updates
    _workoutsController.add(workouts);

    return workouts;
  }

  Future<Workout?> getWorkoutById(String id) async {
    final db = await database;
    final maps = await db.query('workouts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final workout = Workout.fromMap(maps.first);
      final sets = await getWorkoutSets(id);
      return workout.copyWith(sets: sets);
    }
    return null;
  }

  Future<void> insertWorkout(Workout workout) async {
    final db = await database;
    await db.insert('workouts', workout.toMap());

    // Trigger real-time update
    await getAllWorkouts();
  }

  Future<void> updateWorkout(Workout workout) async {
    final db = await database;
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );

    // Trigger real-time update
    await getAllWorkouts();
  }

  Future<void> deleteWorkout(String id) async {
    final db = await database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);

    // Trigger real-time update
    await getAllWorkouts();
  }

  // WorkoutSet CRUD operations with real-time updates
  Future<List<WorkoutSet>> getWorkoutSets(String workoutId) async {
    final db = await database;
    final maps = await db.query(
      'workout_sets',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  Future<void> insertWorkoutSet(WorkoutSet set, String workoutId) async {
    final db = await database;
    final setMap = set.toMap();
    setMap['workoutId'] = workoutId;
    await db.insert('workout_sets', setMap);

    // Trigger real-time update for workouts (includes sets)
    await getAllWorkouts();
  }

  Future<void> updateWorkoutSet(WorkoutSet set, String workoutId) async {
    final db = await database;
    final setMap = set.toMap();
    setMap['workoutId'] = workoutId;
    await db.update(
      'workout_sets',
      setMap,
      where: 'id = ?',
      whereArgs: [set.id],
    );

    // Trigger real-time update for workouts (includes sets)
    await getAllWorkouts();
  }

  Future<void> deleteWorkoutSet(String id) async {
    final db = await database;
    await db.delete('workout_sets', where: 'id = ?', whereArgs: [id]);

    // Trigger real-time update for workouts (includes sets)
    await getAllWorkouts();
  }

  // Weight Entry CRUD operations with real-time updates
  Future<List<WeightEntry>> getAllWeightEntries() async {
    final db = await database;
    final maps = await db.query('weight_entries', orderBy: 'date DESC');
    final entries = maps.map((map) => WeightEntry.fromMap(map)).toList();

    // Emit to stream for real-time updates
    _weightEntriesController.add(entries);

    return entries;
  }

  Future<void> insertWeightEntry(WeightEntry entry) async {
    final db = await database;
    await db.insert('weight_entries', entry.toMap());

    // Trigger real-time update
    await getAllWeightEntries();
  }

  Future<void> updateWeightEntry(WeightEntry entry) async {
    final db = await database;
    await db.update(
      'weight_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );

    // Trigger real-time update
    await getAllWeightEntries();
  }

  Future<void> deleteWeightEntry(String id) async {
    final db = await database;
    await db.delete('weight_entries', where: 'id = ?', whereArgs: [id]);

    // Trigger real-time update
    await getAllWeightEntries();
  }

  Future<WeightEntry?> getWeightEntryById(String id) async {
    final db = await database;
    final maps = await db.query(
      'weight_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return WeightEntry.fromMap(maps.first);
    }
    return null;
  }

  // Goal CRUD operations with real-time updates
  Future<List<Goal>> getAllGoals() async {
    final db = await database;
    final maps = await db.query('goals', orderBy: 'startDate DESC');
    final goals = maps.map((map) => Goal.fromMap(map)).toList();

    // Emit to stream for real-time updates
    _goalsController.add(goals);

    return goals;
  }

  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert('goals', goal.toMap());

    // Trigger real-time update
    await getAllGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );

    // Trigger real-time update
    await getAllGoals();
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);

    // Trigger real-time update
    await getAllGoals();
  }

  Future<Goal?> getGoalById(String id) async {
    final db = await database;
    final maps = await db.query('goals', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }

  // Achievement CRUD operations with real-time updates
  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final maps = await db.query(
      'achievements',
      orderBy: 'isUnlocked DESC, target ASC',
    );
    final achievements = maps.map((map) => Achievement.fromMap(map)).toList();

    // Emit to stream for real-time updates
    _achievementsController.add(achievements);

    return achievements;
  }

  Future<void> updateAchievement(Achievement achievement) async {
    final db = await database;
    await db.update(
      'achievements',
      achievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievement.id],
    );

    // Trigger real-time update
    await getAllAchievements();
  }

  Future<Achievement?> getAchievementById(String id) async {
    final db = await database;
    final maps = await db.query(
      'achievements',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Achievement.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertAchievement(Achievement achievement) async {
    final db = await database;
    await db.insert('achievements', achievement.toMap());

    // Trigger real-time update
    await getAllAchievements();
  }

  Future<void> deleteAchievement(String id) async {
    final db = await database;
    await db.delete('achievements', where: 'id = ?', whereArgs: [id]);

    // Trigger real-time update
    await getAllAchievements();
  }

  // Bulk operations for better performance
  Future<void> insertMultipleWorkoutSets(
    List<WorkoutSet> sets,
    String workoutId,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (final set in sets) {
      final setData = set.toMap();
      setData['workoutId'] = workoutId;
      batch.insert('workout_sets', setData);
    }

    await batch.commit();
    await getWorkoutSets(workoutId); // Trigger real-time update
  }

  Future<void> deleteMultipleWorkoutSets(List<String> setIds) async {
    final db = await database;
    final batch = db.batch();

    for (final setId in setIds) {
      batch.delete('workout_sets', where: 'id = ?', whereArgs: [setId]);
    }

    await batch.commit();
    await getAllWorkouts(); // Trigger real-time update
  }

  Future<void> insertMultipleWeightEntries(List<WeightEntry> entries) async {
    final db = await database;
    final batch = db.batch();

    for (final entry in entries) {
      batch.insert('weight_entries', entry.toMap());
    }

    await batch.commit();
    await getAllWeightEntries(); // Trigger real-time update
  }

  // Search and filter operations
  Future<List<Exercise>> searchExercises(String query) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'name LIKE ? OR targetMuscle LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'workouts',
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'startTime DESC',
    );
    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  Future<List<WeightEntry>> getWeightEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'weight_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => WeightEntry.fromMap(map)).toList();
  }

  Future<List<Goal>> getActiveGoals() async {
    final db = await database;
    final maps = await db.query(
      'goals',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'targetDate ASC',
    );
    return maps.map((map) => Goal.fromMap(map)).toList();
  }

  Future<List<Achievement>> getUnlockedAchievements() async {
    final db = await database;
    final maps = await db.query(
      'achievements',
      where: 'isUnlocked = ?',
      whereArgs: [1],
      orderBy: 'unlockedDate DESC',
    );
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  // Data validation methods for offline integrity
  Future<bool> validateWorkout(Workout workout) async {
    if (workout.name.trim().isEmpty) return false;
    if (workout.startTime.isAfter(DateTime.now())) return false;
    if (workout.endTime != null &&
        workout.endTime!.isBefore(workout.startTime)) {
      return false;
    }
    return true;
  }

  Future<bool> validateExercise(Exercise exercise) async {
    if (exercise.name.trim().isEmpty) return false;

    // Check for duplicate names
    final db = await database;
    final existing = await db.query(
      'exercises',
      where: 'name = ? AND id != ?',
      whereArgs: [exercise.name, exercise.id],
    );
    return existing.isEmpty;
  }

  Future<bool> validateWeightEntry(WeightEntry entry) async {
    if (entry.weight <= 0 || entry.weight > 1000) {
      return false; // Reasonable limits
    }
    if (entry.date.isAfter(DateTime.now())) return false;
    return true;
  }

  // Quick stats methods for offline analytics
  Future<Map<String, dynamic>> getWorkoutStats() async {
    final db = await database;

    final result = <String, dynamic>{};

    // Total workouts this month
    final thisMonth = DateTime.now();
    final startOfMonth = DateTime(thisMonth.year, thisMonth.month, 1);

    result['this_month_workouts'] =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM workouts WHERE startTime >= ?',
            [startOfMonth.millisecondsSinceEpoch],
          ),
        ) ??
        0;

    // Average workout duration
    final avgDuration = await db.rawQuery('''
      SELECT AVG(endTime - startTime) as avg_duration 
      FROM workouts 
      WHERE endTime IS NOT NULL
    ''');

    result['avg_duration_ms'] = avgDuration.first['avg_duration'] ?? 0;

    // Most used exercise
    final topExercise = await db.rawQuery('''
      SELECT e.name, COUNT(*) as usage_count
      FROM workout_sets ws
      JOIN exercises e ON ws.exerciseId = e.id
      GROUP BY e.id, e.name
      ORDER BY usage_count DESC
      LIMIT 1
    ''');

    result['top_exercise'] = topExercise.isNotEmpty
        ? topExercise.first['name']
        : 'None';

    return result;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();

    // Close all stream controllers
    await _exercisesController.close();
    await _workoutsController.close();
    await _weightEntriesController.close();
    await _goalsController.close();
    await _achievementsController.close();
  }

  // Initialize streams - call this after database is ready
  Future<void> initializeStreams() async {
    // Populate initial data for all streams
    await getAllExercises();
    await getAllWorkouts();
    await getAllWeightEntries();
    await getAllGoals();
    await getAllAchievements();
  }

  // Backup and Export operations for offline app
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;

    final data = <String, dynamic>{};
    data['exercises'] = await db.query('exercises');
    data['workouts'] = await db.query('workouts');
    data['workout_sets'] = await db.query('workout_sets');
    data['weight_entries'] = await db.query('weight_entries');
    data['goals'] = await db.query('goals');
    data['achievements'] = await db.query('achievements');
    data['export_date'] = DateTime.now().millisecondsSinceEpoch;
    data['app_version'] = '1.0.0';

    return data;
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    final db = await database;

    try {
      await db.transaction((txn) async {
        // Clear existing data (optional - you might want to merge instead)
        await txn.delete('workout_sets');
        await txn.delete('workouts');
        await txn.delete('weight_entries');
        await txn.delete('goals');
        // Don't clear exercises and achievements as they're defaults

        // Import data
        if (data['workouts'] != null) {
          for (var workout in data['workouts']) {
            await txn.insert('workouts', workout);
          }
        }

        if (data['workout_sets'] != null) {
          for (var set in data['workout_sets']) {
            await txn.insert('workout_sets', set);
          }
        }

        if (data['weight_entries'] != null) {
          for (var entry in data['weight_entries']) {
            await txn.insert('weight_entries', entry);
          }
        }

        if (data['goals'] != null) {
          for (var goal in data['goals']) {
            await txn.insert('goals', goal);
          }
        }
      });
      return true;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }

  // Database statistics for offline app insights
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;

    final stats = <String, int>{};
    stats['total_workouts'] =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM workouts'),
        ) ??
        0;

    stats['total_exercises'] =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM exercises'),
        ) ??
        0;

    stats['total_sets'] =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM workout_sets'),
        ) ??
        0;

    stats['active_goals'] =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM goals WHERE status = ?', [
            'active',
          ]),
        ) ??
        0;

    stats['unlocked_achievements'] =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM achievements WHERE isUnlocked = 1',
          ),
        ) ??
        0;

    return stats;
  }

  // Cleanup old data to manage storage
  Future<void> cleanupOldData({int daysToKeep = 365}) async {
    final db = await database;
    final cutoffDate = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .millisecondsSinceEpoch;

    // Clean up old workouts and their sets
    await db.transaction((txn) async {
      // Get old workout IDs
      final oldWorkouts = await txn.query(
        'workouts',
        columns: ['id'],
        where: 'startTime < ?',
        whereArgs: [cutoffDate],
      );

      // Delete associated workout sets
      for (var workout in oldWorkouts) {
        await txn.delete(
          'workout_sets',
          where: 'workoutId = ?',
          whereArgs: [workout['id']],
        );
      }

      // Delete old workouts
      await txn.delete(
        'workouts',
        where: 'startTime < ?',
        whereArgs: [cutoffDate],
      );
    });
  }
}
