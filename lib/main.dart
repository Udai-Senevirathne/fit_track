import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'blocs/exercise/exercise_bloc.dart';
import 'blocs/workout/workout_bloc.dart';
import 'screens/main_screen.dart';

void main() async {
  print('🚀 Starting Fit Track app...');

  try {
    print('🔧 Ensuring Flutter binding is initialized...');
    WidgetsFlutterBinding.ensureInitialized();
    print('✅ Flutter binding initialized');

    // Initialize SQLite database with real-time streams
    print('🔄 Initializing SQLite database with real-time updates...');
    final databaseHelper = DatabaseHelper();
    await databaseHelper.database; // Initialize database
    await databaseHelper.initializeStreams(); // Initialize real-time streams
    print('✅ SQLite database with real-time streams initialized successfully!');

    print('🔄 Starting Flutter app...');
    runApp(MyApp(databaseHelper: databaseHelper));
    print('✅ App started successfully!');
  } catch (e, stackTrace) {
    print('💥 FATAL ERROR during app initialization!');
    print('📝 Error type: ${e.runtimeType}');
    print('📝 Error message: $e');
    print('📝 Stack trace:');
    print(stackTrace.toString());

    // Try to show error in UI
    runApp(
      MaterialApp(
        title: 'Fit Track - Error',
        home: Scaffold(
          appBar: AppBar(title: const Text('Database Error')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Database Initialization Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Type: ${e.runtimeType}'),
                const SizedBox(height: 8),
                Text('Message: $e'),
                const SizedBox(height: 16),
                const Text(
                  'Possible Solutions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('1. Run: flutter clean && flutter pub get'),
                const Text('2. Restart the app'),
                const Text('3. Check if device has sufficient storage'),
                const Text('4. Try running on a different device/emulator'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  const MyApp({super.key, required this.databaseHelper});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DatabaseHelper>(create: (context) => databaseHelper),
        RepositoryProvider<ExerciseRepository>(
          create: (context) =>
              ExerciseRepository(context.read<DatabaseHelper>()),
        ),
        RepositoryProvider<WorkoutRepository>(
          create: (context) =>
              WorkoutRepository(context.read<DatabaseHelper>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ExerciseBloc>(
            create: (context) =>
                ExerciseBloc(context.read<ExerciseRepository>()),
          ),
          BlocProvider<WorkoutBloc>(
            create: (context) => WorkoutBloc(context.read<WorkoutRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Fit Track - Real-Time SQLite',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
