import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class Exercise {
  final int id;
  final String name;
  final String description;
  final List<ExerciseImage> images;
  final List<int> muscles;
  final List<int> musclesSecondary;
  final List<int> equipment;
  final String category;
  final String? language;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.muscles,
    required this.musclesSecondary,
    required this.equipment,
    required this.category,
    this.language,
  });

  static List<int> _parseIntList(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((item) {
        if (item is int) {
          return item;
        } else if (item is Map<String, dynamic>) {
          return item['id'] as int? ?? 0;
        } else {
          return int.tryParse(item.toString()) ?? 0;
        }
      }).toList();
    }

    return [];
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // Obter nome da primeira tradução disponível
    String exerciseName = 'Exercício sem nome';
    String exerciseDescription = '';

    if (json['translations'] != null && json['translations'].isNotEmpty) {
      final translation = json['translations'][0];
      exerciseName = translation['name'] ?? 'Exercício sem nome';
      exerciseDescription = translation['description'] ?? '';

      // Remover tags HTML da descrição
      exerciseDescription = exerciseDescription
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .trim();
    }

    return Exercise(
      id: json['id'] ?? 0,
      name: TranslationService.translate(exerciseName),
      description: TranslationService.translateDescription(exerciseDescription),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ExerciseImage.fromJson(e))
              .toList() ??
          [],
      muscles: _parseIntList(json['muscles']),
      musclesSecondary: _parseIntList(json['muscles_secondary']),
      equipment: _parseIntList(json['equipment']),
      category: json['category']?.toString() ?? '',
      language: json['language']?.toString(),
    );
  }
}

class ExerciseImage {
  final int id;
  final String image;
  final bool isMain;

  ExerciseImage({required this.id, required this.image, required this.isMain});

  factory ExerciseImage.fromJson(Map<String, dynamic> json) {
    return ExerciseImage(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      isMain: json['is_main'] ?? false,
    );
  }
}

class Muscle {
  final int id;
  final String name;
  final String namePt;
  final bool isFront;

  Muscle({
    required this.id,
    required this.name,
    required this.namePt,
    required this.isFront,
  });

  factory Muscle.fromJson(Map<String, dynamic> json) {
    return Muscle(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      namePt: json['name_pt'] ?? json['name'] ?? '',
      isFront: json['is_front'] ?? true,
    );
  }
}

class Equipment {
  final int id;
  final String name;

  Equipment({required this.id, required this.name});

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class WorkoutPlan {
  final String name;
  final String description;
  final WorkoutLevel level;
  final WorkoutType type;
  final List<Exercise> exercises;
  final int estimatedDuration; // em minutos
  final List<String> targetMuscles;

  WorkoutPlan({
    required this.name,
    required this.description,
    required this.level,
    required this.type,
    required this.exercises,
    required this.estimatedDuration,
    required this.targetMuscles,
  });
}

enum WorkoutLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case WorkoutLevel.beginner:
        return 'Iniciante';
      case WorkoutLevel.intermediate:
        return 'Intermediário';
      case WorkoutLevel.advanced:
        return 'Avançado';
    }
  }

  Color get color {
    switch (this) {
      case WorkoutLevel.beginner:
        return Colors.green;
      case WorkoutLevel.intermediate:
        return Colors.orange;
      case WorkoutLevel.advanced:
        return Colors.red;
    }
  }
}

enum WorkoutType {
  cardio,
  strength,
  flexibility,
  fullBody;

  String get displayName {
    switch (this) {
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.strength:
        return 'Força';
      case WorkoutType.flexibility:
        return 'Flexibilidade';
      case WorkoutType.fullBody:
        return 'Corpo Inteiro';
    }
  }

  IconData get icon {
    switch (this) {
      case WorkoutType.cardio:
        return Icons.directions_run;
      case WorkoutType.strength:
        return Icons.fitness_center;
      case WorkoutType.flexibility:
        return Icons.self_improvement;
      case WorkoutType.fullBody:
        return Icons.accessibility_new;
    }
  }
}

enum MuscleGroup {
  chest,
  back,
  shoulders,
  arms,
  legs,
  core,
  fullBody;

  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Peito';
      case MuscleGroup.back:
        return 'Costas';
      case MuscleGroup.shoulders:
        return 'Ombros';
      case MuscleGroup.arms:
        return 'Braços';
      case MuscleGroup.legs:
        return 'Pernas';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.fullBody:
        return 'Corpo Inteiro';
    }
  }

  IconData get icon {
    switch (this) {
      case MuscleGroup.chest:
        return Icons.fitness_center;
      case MuscleGroup.back:
        return Icons.back_hand;
      case MuscleGroup.shoulders:
        return Icons.sports_gymnastics;
      case MuscleGroup.arms:
        return Icons.sports_martial_arts;
      case MuscleGroup.legs:
        return Icons.directions_walk;
      case MuscleGroup.core:
        return Icons.center_focus_strong;
      case MuscleGroup.fullBody:
        return Icons.accessibility_new;
    }
  }
}
