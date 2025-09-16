import 'package:equatable/equatable.dart';

class WorkoutSet extends Equatable {
  final String id;
  final String exerciseId;
  final int reps;
  final double weight;
  final int? restTime; // in seconds
  final DateTime createdAt;

  const WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.reps,
    required this.weight,
    this.restTime,
    required this.createdAt,
  });

  WorkoutSet copyWith({
    String? id,
    String? exerciseId,
    int? reps,
    double? weight,
    int? restTime,
    DateTime? createdAt,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'reps': reps,
      'weight': weight,
      'restTime': restTime,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'] as String,
      exerciseId: map['exerciseId'] as String,
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
      restTime: map['restTime'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    reps,
    weight,
    restTime,
    createdAt,
  ];
}
