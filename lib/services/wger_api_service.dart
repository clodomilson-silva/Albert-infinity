import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_models.dart';

class WgerApiService {
  static const String baseUrl = 'https://wger.de/api/v2';
  static WgerApiService? _instance;

  static WgerApiService get instance {
    _instance ??= WgerApiService._internal();
    return _instance!;
  }

  WgerApiService._internal();

  // Cache para evitar requisições desnecessárias
  List<Exercise>? _cachedExercises;
  List<Muscle>? _cachedMuscles;
  List<Equipment>? _cachedEquipment;
  DateTime? _lastCacheUpdate;

  bool get _shouldUpdateCache {
    // Sempre atualizar cache para testar as mudanças
    return true;
  }

  // Buscar todos os exercícios
  Future<List<Exercise>> getExercises() async {
    if (_cachedExercises != null && !_shouldUpdateCache) {
      return _cachedExercises!;
    }

    try {
      // Primeiro, buscar exercícios que sabemos que têm imagens para teste
      // Exercícios conhecidos com imagens (primeiros 50 exercícios com imagens encontrados)
      List<int> exerciseIdsWithImages = [
        1022,
        822,
        828,
        927,
        958,
        50,
        984,
        988,
        959,
        999,
        1000,
        92,
        83,
        81,
        94,
        75,
        91,
        73,
        76,
        95,
        78,
        161,
        167,
        171,
        183,
        187,
        189,
        193,
        197,
        199,
        233,
        237,
        251,
        253,
        261,
        263,
        271,
        275,
        277,
        283,
        285,
        287,
        289,
        291,
        293,
        295,
        297,
        299,
        301,
        303,
      ];

      List<Exercise> exercises = [];

      print(
        '🔄 Buscando ${exerciseIdsWithImages.length} exercícios com imagens...',
      );

      for (int exerciseId in exerciseIdsWithImages.take(30)) {
        // Aumentar para 30 exercícios
        try {
          final exerciseResponse = await http.get(
            Uri.parse('$baseUrl/exerciseinfo/$exerciseId/'),
            headers: {'Accept': 'application/json'},
          );

          if (exerciseResponse.statusCode == 200) {
            final exerciseData = json.decode(exerciseResponse.body);
            final exercise = Exercise.fromJson(exerciseData);

            // Buscar imagens para este exercício
            final images = await getExerciseImages(exercise.id);

            // Só adicionar se realmente tem imagens
            if (images.isNotEmpty) {
              // Criar exercício com imagens usando nome original da API
              final exerciseWithImages = Exercise(
                id: exercise.id,
                name: exercise.name.isNotEmpty
                    ? exercise.name
                    : 'Exercise ${exercise.id}',
                description: exercise.description,
                images: images,
                muscles: exercise.muscles,
                musclesSecondary: exercise.musclesSecondary,
                equipment: exercise.equipment,
                category: exercise.category,
                language: exercise.language,
              );

              exercises.add(exerciseWithImages);
              print(
                '✅ Exercício ${exercise.id}: ${exerciseWithImages.name} (${images.length} imagens)',
              );
            } else {
              print(
                '⚠️  Exercício ${exercise.id}: ${exercise.name} (sem imagens válidas)',
              );
            }
          }
        } catch (e) {
          print('❌ Erro ao buscar exercício $exerciseId: $e');
        }

        // Pequeno delay para não sobrecarregar a API
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Se conseguimos alguns exercícios, vamos adicionar alguns exercícios padrão também
      exercises.addAll(_getDefaultExercises());

      _cachedExercises = exercises;
      _lastCacheUpdate = DateTime.now();
      print('✅ Total de exercícios carregados: ${exercises.length}');
      return exercises;
    } catch (e) {
      print('❌ Erro geral ao buscar exercícios: $e');
      // Retornar exercícios padrão em caso de erro
      return _getDefaultExercises();
    }
  }

  // Buscar imagens de um exercício específico
  Future<List<ExerciseImage>> getExerciseImages(int exerciseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exerciseimage/?exercise=$exerciseId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((imageJson) => ExerciseImage.fromJson(imageJson))
            .toList();
      }
    } catch (e) {
      print('Erro ao buscar imagens do exercício $exerciseId: $e');
    }
    return [];
  }

  // Buscar músculos
  Future<List<Muscle>> getMuscles() async {
    if (_cachedMuscles != null && !_shouldUpdateCache) {
      return _cachedMuscles!;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/muscle/'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final muscles = (data['results'] as List)
            .map((muscleJson) => Muscle.fromJson(muscleJson))
            .toList();

        _cachedMuscles = muscles;
        return muscles;
      }
    } catch (e) {
      print('Erro ao buscar músculos: $e');
    }
    return _getDefaultMuscles();
  }

  // Buscar equipamentos
  Future<List<Equipment>> getEquipment() async {
    if (_cachedEquipment != null && !_shouldUpdateCache) {
      return _cachedEquipment!;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipment/'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final equipment = (data['results'] as List)
            .map((equipmentJson) => Equipment.fromJson(equipmentJson))
            .toList();

        _cachedEquipment = equipment;
        return equipment;
      }
    } catch (e) {
      print('Erro ao buscar equipamentos: $e');
    }
    return _getDefaultEquipment();
  }

  // Buscar exercícios por grupo muscular
  Future<List<Exercise>> getExercisesByMuscleGroup(
    MuscleGroup muscleGroup,
  ) async {
    final allExercises = await getExercises();

    // Mapear grupos musculares para IDs da API
    List<int> targetMuscleIds = _getMuscleIdsForGroup(muscleGroup);

    return allExercises.where((exercise) {
      return exercise.muscles.any(
            (muscleId) => targetMuscleIds.contains(muscleId),
          ) ||
          exercise.musclesSecondary.any(
            (muscleId) => targetMuscleIds.contains(muscleId),
          );
    }).toList();
  }

  // Gerar plano de treino baseado no nível e tipo
  Future<WorkoutPlan> generateWorkoutPlan({
    required WorkoutLevel level,
    required WorkoutType type,
    MuscleGroup? targetMuscleGroup,
  }) async {
    List<Exercise> exercises;

    if (targetMuscleGroup != null) {
      exercises = await getExercisesByMuscleGroup(targetMuscleGroup);
    } else {
      exercises = await getExercises();
    }

    // Filtrar exercícios por tipo se necessário
    exercises = _filterExercisesByType(exercises, type);

    // Selecionar exercícios baseado no nível
    final selectedExercises = _selectExercisesForLevel(exercises, level);

    return WorkoutPlan(
      name: _generateWorkoutName(level, type, targetMuscleGroup),
      description: _generateWorkoutDescription(level, type, targetMuscleGroup),
      level: level,
      type: type,
      exercises: selectedExercises,
      estimatedDuration: _calculateDuration(selectedExercises, level),
      targetMuscles: _getTargetMuscleNames(selectedExercises),
    );
  }

  // Métodos auxiliares privados
  List<int> _getMuscleIdsForGroup(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return [4]; // Peitorais
      case MuscleGroup.back:
        return [12, 13]; // Latíssimo, Trapézio
      case MuscleGroup.shoulders:
        return [2]; // Deltoides
      case MuscleGroup.arms:
        return [1, 3, 5]; // Bíceps, Tríceps, Antebraço
      case MuscleGroup.legs:
        return [8, 10, 11]; // Quadríceps, Glúteos, Panturrilha
      case MuscleGroup.core:
        return [6, 14]; // Abdominais, Oblíquos
      case MuscleGroup.fullBody:
        return [1, 2, 3, 4, 5, 6, 8, 10, 11, 12, 13, 14];
    }
  }

  List<Exercise> _filterExercisesByType(
    List<Exercise> exercises,
    WorkoutType type,
  ) {
    // Filtrar exercícios baseado no tipo (isso pode ser expandido)
    switch (type) {
      case WorkoutType.cardio:
        // Exercícios que não requerem equipamento pesado
        return exercises
            .where((e) => e.equipment.isEmpty || e.equipment.contains(7))
            .toList();
      case WorkoutType.strength:
        // Exercícios com pesos ou equipamentos
        return exercises.where((e) => e.equipment.isNotEmpty).toList();
      case WorkoutType.flexibility:
        // Exercícios de alongamento
        return exercises
            .where(
              (e) =>
                  e.description.toLowerCase().contains('stretch') ||
                  e.description.toLowerCase().contains('yoga'),
            )
            .toList();
      case WorkoutType.fullBody:
        return exercises;
    }
  }

  List<Exercise> _selectExercisesForLevel(
    List<Exercise> exercises,
    WorkoutLevel level,
  ) {
    int maxExercises;
    switch (level) {
      case WorkoutLevel.beginner:
        maxExercises = 6;
        break;
      case WorkoutLevel.intermediate:
        maxExercises = 8;
        break;
      case WorkoutLevel.advanced:
        maxExercises = 12;
        break;
    }

    exercises.shuffle();
    return exercises.take(maxExercises).toList();
  }

  String _generateWorkoutName(
    WorkoutLevel level,
    WorkoutType type,
    MuscleGroup? muscleGroup,
  ) {
    String baseName = type.displayName;
    if (muscleGroup != null) {
      baseName += ' - ${muscleGroup.displayName}';
    }
    return '$baseName ${level.displayName}';
  }

  String _generateWorkoutDescription(
    WorkoutLevel level,
    WorkoutType type,
    MuscleGroup? muscleGroup,
  ) {
    String description = 'Treino de ${type.displayName.toLowerCase()}';
    if (muscleGroup != null) {
      description += ' focado em ${muscleGroup.displayName.toLowerCase()}';
    }
    description += ' para nível ${level.displayName.toLowerCase()}.';
    return description;
  }

  int _calculateDuration(List<Exercise> exercises, WorkoutLevel level) {
    int baseMinutes = exercises.length * 3; // 3 minutos por exercício
    switch (level) {
      case WorkoutLevel.beginner:
        return baseMinutes;
      case WorkoutLevel.intermediate:
        return (baseMinutes * 1.3).round();
      case WorkoutLevel.advanced:
        return (baseMinutes * 1.6).round();
    }
  }

  List<String> _getTargetMuscleNames(List<Exercise> exercises) {
    Set<String> muscleNames = {};
    for (var exercise in exercises) {
      // Adicionar nomes dos músculos (isso pode ser expandido com tradução)
      muscleNames.addAll(exercise.muscles.map((id) => 'Músculo $id'));
    }
    return muscleNames.toList();
  }

  // Exercícios padrão em caso de falha na API
  List<Exercise> _getDefaultExercises() {
    return [
      Exercise(
        id: 1,
        name: 'Push-ups',
        description: 'Basic exercise for chest, shoulders and triceps',
        images: [],
        muscles: [4], // Chest
        musclesSecondary: [2, 3], // Shoulders, Triceps
        equipment: [],
        category: '1',
      ),
      Exercise(
        id: 2,
        name: 'Squats',
        description: 'Fundamental exercise for legs and glutes',
        images: [],
        muscles: [8], // Quadriceps
        musclesSecondary: [10], // Glutes
        equipment: [],
        category: '1',
      ),
      Exercise(
        id: 3,
        name: 'Plank',
        description: 'Isometric exercise for core strengthening',
        images: [],
        muscles: [6], // Abs
        musclesSecondary: [14], // Obliques
        equipment: [],
        category: '1',
      ),
    ];
  }

  List<Muscle> _getDefaultMuscles() {
    return [
      Muscle(id: 1, name: 'Biceps', namePt: 'Bíceps', isFront: true),
      Muscle(id: 2, name: 'Deltoids', namePt: 'Deltoides', isFront: true),
      Muscle(id: 3, name: 'Triceps', namePt: 'Tríceps', isFront: false),
      Muscle(id: 4, name: 'Pectorals', namePt: 'Peitorais', isFront: true),
      Muscle(id: 6, name: 'Abdominals', namePt: 'Abdominais', isFront: true),
      Muscle(id: 8, name: 'Quadriceps', namePt: 'Quadríceps', isFront: true),
      Muscle(id: 10, name: 'Glutes', namePt: 'Glúteos', isFront: false),
    ];
  }

  List<Equipment> _getDefaultEquipment() {
    return [
      Equipment(id: 1, name: 'Barbell'),
      Equipment(id: 2, name: 'Dumbbell'),
      Equipment(id: 7, name: 'Body weight'),
    ];
  }
}
