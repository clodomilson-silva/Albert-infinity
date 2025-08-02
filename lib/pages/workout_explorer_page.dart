import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/exercise_models.dart';
import '../services/wger_api_service.dart';
import 'workout_detail_page.dart';

class WorkoutExplorerPage extends StatefulWidget {
  final WorkoutLevel? initialLevel;

  const WorkoutExplorerPage({super.key, this.initialLevel});

  @override
  State<WorkoutExplorerPage> createState() => _WorkoutExplorerPageState();
}

class _WorkoutExplorerPageState extends State<WorkoutExplorerPage> {
  final WgerApiService _apiService = WgerApiService.instance;
  bool _isLoading = false;
  List<WorkoutPlan> _workoutPlans = [];
  WorkoutLevel _selectedLevel = WorkoutLevel.beginner;
  MuscleGroup? _selectedMuscleGroup;

  @override
  void initState() {
    super.initState();
    if (widget.initialLevel != null) {
      _selectedLevel = widget.initialLevel!;
    }
    _loadWorkoutPlans();
  }

  Future<void> _loadWorkoutPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<WorkoutPlan> plans = [];

      // Gerar planos para diferentes tipos
      for (WorkoutType type in WorkoutType.values) {
        final plan = await _apiService.generateWorkoutPlan(
          level: _selectedLevel,
          type: type,
          targetMuscleGroup: _selectedMuscleGroup,
        );
        plans.add(plan);
      }

      setState(() {
        _workoutPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar treinos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          "Explorar Treinos",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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

          // Lista de treinos
          Expanded(
            child: _isLoading ? _buildLoadingWidget() : _buildWorkoutList(),
          ),
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
            children: WorkoutLevel.values.map((level) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLevel = level;
                      });
                      _loadWorkoutPlans();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedLevel == level
                            ? level.color
                            : Colors.grey.shade800,
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
              itemCount: MuscleGroup.values.length + 1, // +1 para "Todos"
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Opção "Todos"
                  return _buildMuscleGroupCard(
                    name: "Todos",
                    icon: Icons.fitness_center,
                    isSelected: _selectedMuscleGroup == null,
                    onTap: () {
                      setState(() {
                        _selectedMuscleGroup = null;
                      });
                      _loadWorkoutPlans();
                    },
                  );
                }

                final muscleGroup = MuscleGroup.values[index - 1];
                return _buildMuscleGroupCard(
                  name: muscleGroup.displayName,
                  icon: muscleGroup.icon,
                  isSelected: _selectedMuscleGroup == muscleGroup,
                  onTap: () {
                    setState(() {
                      _selectedMuscleGroup = muscleGroup;
                    });
                    _loadWorkoutPlans();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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
          Text('Carregando treinos...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildWorkoutList() {
    if (_workoutPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino encontrado',
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
      itemCount: _workoutPlans.length,
      itemBuilder: (context, index) {
        final plan = _workoutPlans[index];
        return _buildWorkoutPlanCard(plan);
      },
    );
  }

  Widget _buildWorkoutPlanCard(WorkoutPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailPage(workoutPlan: plan),
            ),
          );
        },
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
                      color: plan.level.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      plan.type.icon,
                      color: plan.level.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.description,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: plan.level.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plan.level.displayName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.timer,
                    text: '${plan.estimatedDuration} min',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    icon: Icons.fitness_center,
                    text: '${plan.exercises.length} exercícios',
                  ),
                ],
              ),
              if (plan.targetMuscles.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: plan.targetMuscles.take(3).map((muscle) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        muscle,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF7D4FFF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF7D4FFF), size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF7D4FFF),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
