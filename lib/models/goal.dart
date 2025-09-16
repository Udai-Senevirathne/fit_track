import 'package:equatable/equatable.dart';

enum GoalType { weightLoss, weightGain, strengthGain, workoutFrequency, custom }

enum GoalStatus { active, completed, paused, failed }

class Goal extends Equatable {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final GoalStatus status;
  final double targetValue;
  final double currentValue;
  final String unit;
  final DateTime startDate;
  final DateTime targetDate;
  final DateTime? completedDate;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.startDate,
    required this.targetDate,
    this.completedDate,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    GoalStatus? status,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? completedDate,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  double get progressPercentage {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue * 100).clamp(0, 100);
  }

  bool get isCompleted => status == GoalStatus.completed;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'startDate': startDate.millisecondsSinceEpoch,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'completedDate': completedDate?.millisecondsSinceEpoch,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: GoalType.values.firstWhere((e) => e.name == map['type']),
      status: GoalStatus.values.firstWhere((e) => e.name == map['status']),
      targetValue: (map['targetValue'] as num).toDouble(),
      currentValue: (map['currentValue'] as num).toDouble(),
      unit: map['unit'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate'] as int),
      completedDate: map['completedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'] as int)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    status,
    targetValue,
    currentValue,
    unit,
    startDate,
    targetDate,
    completedDate,
  ];
}
