import 'package:equatable/equatable.dart';

enum AchievementType {
  firstWorkout,
  consistentWeek,
  consistentMonth,
  strengthMilestone,
  volumeMilestone,
  workoutCount,
  weightGoal,
  custom,
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final double progress;
  final double target;
  final String unit;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.iconName,
    required this.isUnlocked,
    this.unlockedDate,
    required this.progress,
    required this.target,
    required this.unit,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    String? iconName,
    bool? isUnlocked,
    DateTime? unlockedDate,
    double? progress,
    double? target,
    String? unit,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      unit: unit ?? this.unit,
    );
  }

  double get progressPercentage {
    if (target == 0) return 0;
    return (progress / target * 100).clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'iconName': iconName,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedDate': unlockedDate?.millisecondsSinceEpoch,
      'progress': progress,
      'target': target,
      'unit': unit,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: AchievementType.values.firstWhere((e) => e.name == map['type']),
      iconName: map['iconName'] as String,
      isUnlocked: (map['isUnlocked'] as int) == 1,
      unlockedDate: map['unlockedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['unlockedDate'] as int)
          : null,
      progress: (map['progress'] as num).toDouble(),
      target: (map['target'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    iconName,
    isUnlocked,
    unlockedDate,
    progress,
    target,
    unit,
  ];
}
