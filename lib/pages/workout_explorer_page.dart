import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trainsmart_models.dart';
import '../services/trainsmart_api_service.dart';

class WorkoutExplorerPage extends StatefulWidget {
  final NivelExercicio? initialLevel;

  const WorkoutExplorerPage({super.key, this.initialLevel});

  @override
  State<WorkoutExplorerPage> createState() => _WorkoutExplorerPageState();
}

class _WorkoutExplorerPageState extends State<WorkoutExplorerPage> {
  final TrainSmartApiService _apiService = TrainSmartApiService.instance;
  bool _isLoading = false;
  List<TrainSmartExercise> _exercises = [];
  NivelExercicio _selectedLevel = NivelExercicio.iniciante;
  String? _selectedGrupoMuscular;
  List<String> _gruposMusculares = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLevel != null) {
      _selectedLevel = widget.initialLevel!;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadGruposMusculares();
    await _loadExercises();
  }

  Future<void> _loadGruposMusculares() async {
    try {
      final grupos = await _apiService.getGruposMusculares();
      setState(() {
        _gruposMusculares = grupos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar grupos musculares: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = await _apiService.getExercises(
        grupoMuscular: _selectedGrupoMuscular,
        limit: 50,
      );

      // Filtrar por nível se necessário
      List<TrainSmartExercise> filteredExercises = exercises;
      if (_selectedLevel != NivelExercicio.iniciante) {
        filteredExercises = exercises.where((exercise) {
          final exerciseLevel = exercise.nivel?.toLowerCase() ?? 'iniciante';
          return exerciseLevel == _getLevelString(_selectedLevel);
        }).toList();
      }

      setState(() {
        _exercises = filteredExercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar exercícios: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getLevelString(NivelExercicio nivel) {
    switch (nivel) {
      case NivelExercicio.iniciante:
        return 'iniciante';
      case NivelExercicio.intermediario:
        return 'intermediario';
      case NivelExercicio.avancado:
        return 'avancado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Explorar Exercícios",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilters(),

          // Lista de exercícios
          Expanded(child: _isLoading ? _buildLoadingWidget() : _buildExerciseList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seleção de nível
          Text(
            "Nível de Dificuldade",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: NivelExercicio.values.map((level) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLevel = level;
                      });
                      _loadExercises();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedLevel == level ? level.cor : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        level.displayName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Seleção de grupo muscular
          Text(
            "Grupo Muscular",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _gruposMusculares.length + 1, // +1 para "Todos"
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Opção "Todos"
                  return _buildMuscleGroupCard(
                    name: "Todos",
                    icon: Icons.fitness_center,
                    isSelected: _selectedGrupoMuscular == null,
                    onTap: () {
                      setState(() {
                        _selectedGrupoMuscular = null;
                      });
                      _loadExercises();
                    },
                  );
                }

                final grupoMuscular = _gruposMusculares[index - 1];
                return _buildMuscleGroupCard(
                  name: grupoMuscular,
                  icon: _getIconForMuscleGroup(grupoMuscular),
                  isSelected: _selectedGrupoMuscular == grupoMuscular,
                  onTap: () {
                    setState(() {
                      _selectedGrupoMuscular = grupoMuscular;
                    });
                    _loadExercises();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMuscleGroup(String grupo) {
    switch (grupo.toLowerCase()) {
      case 'peito':
        return Icons.fitness_center;
      case 'costas':
        return Icons.view_column;
      case 'pernas':
        return Icons.directions_run;
      case 'braços':
      case 'bracos':
        return Icons.sports_handball;
      case 'ombros':
        return Icons.expand_more;
      case 'abdômen':
      case 'abdomen':
        return Icons.crop_square;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _buildMuscleGroupCard({
    required String name,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7D4FFF) : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF7D4FFF)),
          SizedBox(height: 16),
          Text('Carregando exercícios...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            Text(
              'Nenhum exercício encontrado',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(TrainSmartExercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: exercise.corNivel.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(exercise.iconeGrupoMuscular, color: exercise.corNivel, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.nome,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.descricao.length > 80
                            ? '${exercise.descricao.substring(0, 80)}...'
                            : exercise.descricao,
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: exercise.corNivel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.nivel ?? "Iniciante",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // GIF do exercício se disponível
            if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    exercise.gifUrl!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: 200,
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF7D4FFF),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: 200,
                        color: Colors.grey.shade800,
                        child: Center(
                          child: Icon(
                            exercise.iconeGrupoMuscular,
                            color: const Color(0xFF7D4FFF),
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.category,
                  text: exercise.grupoMuscular,
                  color: Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.fitness_center,
                  text: exercise.equipamento,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

extension NivelExercicioExtension on NivelExercicio {
  Color get cor {
    switch (this) {
      case NivelExercicio.iniciante:
        return Colors.green;
      case NivelExercicio.intermediario:
        return Colors.orange;
      case NivelExercicio.avancado:
        return Colors.red;
    }
  }
}
