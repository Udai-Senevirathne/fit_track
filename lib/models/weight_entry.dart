import 'package:equatable/equatable.dart';

class WeightEntry extends Equatable {
  final String id;
  final double weight;
  final DateTime date;
  final String? notes;

  const WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    this.notes,
  });

  WeightEntry copyWith({
    String? id,
    double? weight,
    DateTime? date,
    String? notes,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'date': date.millisecondsSinceEpoch,
      'note': notes,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] as String,
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      notes: map['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, weight, date, notes];
}
