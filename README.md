# Fit Track - Offline Gym Tracking App

A simple, offline gym tracking application built with Flutter using the BLoC (Business Logic Component) architecture pattern.

## Features

### Core Functionality
- **Offline Storage**: All data is stored locally using SQLite database
- **BLoC Architecture**: Clean separation of business logic and UI components
- **Real-time Tracking**: Track workouts as you perform them

### Workout Management
- Create and start new workouts
- Add multiple sets to exercises during workouts
- Track reps, weight, and rest time for each set
- End workouts when complete
- View workout history and details

### Exercise Library
- Pre-loaded exercise database with common gym exercises
- Exercises organized by muscle groups (Chest, Back, Legs, etc.)
- Categories include Strength and Bodyweight exercises
- Exercise details with descriptions

### Statistics & Analytics
- Workout duration tracking
- Total sets and exercises per workout
- Volume calculation (reps × weight)
- Historical workout data

## Architecture

### BLoC Pattern Implementation
```
├── lib/
│   ├── models/           # Data models (Exercise, Workout, WorkoutSet)
│   ├── data/
│   │   ├── database/     # SQLite database helper
│   │   └── repositories/ # Data access layer
│   ├── blocs/           # Business logic components
│   │   ├── exercise/    # Exercise management BLoC
│   │   └── workout/     # Workout management BLoC
│   ├── screens/         # UI screens
│   └── widgets/         # Reusable UI components
```

### Data Models
- **Exercise**: Represents gym exercises with name, category, muscle group
- **Workout**: Represents workout sessions with start/end times
- **WorkoutSet**: Individual sets within workouts (reps, weight, exercise)

### Key BLoCs
- **ExerciseBloc**: Manages exercise data and operations
- **WorkoutBloc**: Handles workout lifecycle and set management

## Screens

1. **Home Screen**: Dashboard showing workout history
2. **Start Workout Screen**: Create and begin new workouts
3. **Workout In Progress Screen**: Real-time workout tracking
4. **Workout Detail Screen**: View completed workout details

## Database Schema

### Tables
- `exercises`: Store exercise definitions
- `workouts`: Store workout sessions
- `workout_sets`: Store individual sets with foreign keys

### Default Data
The app comes pre-loaded with common exercises:
- Bench Press (Chest)
- Squat (Legs)
- Deadlift (Back)
- Pull Up (Back)
- Push Up (Chest)

## Getting Started

### Prerequisites
- Flutter SDK
- Android/iOS development environment

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Dependencies
- `flutter_bloc`: State management
- `bloc`: Core BLoC functionality
- `equatable`: Object equality comparisons
- `sqflite`: Local SQLite database
- `intl`: Date/time formatting
- `uuid`: Unique ID generation

## Usage

### Starting a Workout
1. Tap the '+' button on the home screen
2. Enter workout name and optional description
3. Browse available exercises by muscle group
4. Tap "Start Workout"

### Adding Sets
1. During a workout, tap the '+' button
2. Select an exercise from the dropdown
3. Enter reps and weight
4. Tap "Add" to save the set

### Viewing History
1. Workout history appears on the home screen
2. Tap any workout to view detailed information
3. See statistics like duration, total volume, and exercise breakdown

## Offline Capability

This app is designed to work completely offline:
- All data stored in local SQLite database
- No network connectivity required
- Data persists between app sessions
- Suitable for gym environments with poor connectivity

## Future Enhancements

Potential improvements for future versions:
- Exercise creation and customization
- Workout templates and routines
- Progress tracking and charts
- Data export functionality
- Backup and restore features
- Rest timer with notifications
- Exercise instruction videos/images
