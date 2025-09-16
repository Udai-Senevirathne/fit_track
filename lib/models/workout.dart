import 'package:equatable/equatable.dart';
import 'workout_set.dart';

class Workout extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final List<WorkoutSet> sets;

  const Workout({
    required this.id,
    required this.name,
    this.description,
    required this.startTime,
    this.endTime,
    required this.sets,
  });

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    List<WorkoutSet>? sets,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sets: sets ?? this.sets,
    );
  }

  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  bool get isCompleted => endTime != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int)
          : null,
      sets: const [], // Sets will be loaded separately
    );
  }

  @override
  List<Object?> get props => [id, name, description, startTime, endTime, sets];
}
