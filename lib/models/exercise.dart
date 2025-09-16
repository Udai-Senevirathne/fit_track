import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String muscleGroup;
  final DateTime createdAt;

  const Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.muscleGroup,
    required this.createdAt,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? muscleGroup,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'muscleGroup': muscleGroup,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      muscleGroup: map['muscleGroup'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    muscleGroup,
    createdAt,
  ];
}
