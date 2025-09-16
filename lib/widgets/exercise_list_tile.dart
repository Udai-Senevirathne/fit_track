import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ExerciseListTile({
    super.key,
    required this.exercise,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMuscleGroupColor(exercise.muscleGroup),
          child: Text(
            exercise.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.muscleGroup),
            Text(
              exercise.category,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Color _getMuscleGroupColor(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Colors.red;
      case 'back':
        return Colors.green;
      case 'legs':
        return Colors.blue;
      case 'shoulders':
        return Colors.orange;
      case 'arms':
        return Colors.purple;
      case 'core':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
