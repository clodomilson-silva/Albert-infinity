import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trainsmart_models.dart';
import '../services/trainsmart_api_service.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String grupoMuscular;
  final NivelExercicio nivel;

  const WorkoutDetailPage({super.key, required this.grupoMuscular, required this.nivel});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  final TrainSmartApiService _apiService = TrainSmartApiService.instance;
  bool _isWorkoutStarted = false;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  final int _totalSets = 3;
  bool _isResting = false;
  int _restTime = 30; // segundos
  bool _isLoading = true;
  List<TrainSmartExercise> _exercises = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final exercises = await _apiService.getExercises(
        grupoMuscular: widget.grupoMuscular,
        limit: 10,
      );

      // Filtrar por nível se necessário
      List<TrainSmartExercise> filteredExercises = exercises;
      if (widget.nivel != NivelExercicio.iniciante) {
        filteredExercises = exercises.where((exercise) {
          final exerciseLevel = exercise.nivel?.toLowerCase() ?? 'iniciante';
          return exerciseLevel == _getLevelString(widget.nivel);
        }).toList();
      }

      setState(() {
        _exercises = filteredExercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar exercícios: $e';
      });
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
          '${widget.grupoMuscular} - ${widget.nivel.displayName}',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareWorkout,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : (_isWorkoutStarted ? _buildWorkoutSession() : _buildWorkoutPreview()),
      bottomNavigationBar: _buildBottomBar(),
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

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          SizedBox(height: 16),
          Text(
            'Erro ao carregar exercícios',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadExercises,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7D4FFF),
              foregroundColor: Colors.white,
            ),
            child: Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações gerais do treino
          _buildWorkoutHeader(),

          const SizedBox(height: 30),

          // Lista de exercícios
          Text(
            "Exercícios (${_exercises.length})",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),

          if (_exercises.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.fitness_center, color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum exercício encontrado',
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            ..._exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _buildExerciseCard(exercise, index + 1);
            }),
        ],
      ),
    );
  }

  Widget _buildWorkoutSession() {
    if (_exercises.isEmpty) {
      return const Center(
        child: Text('Nenhum exercício disponível', style: TextStyle(color: Colors.white)),
      );
    }

    final currentExercise = _exercises[_currentExerciseIndex];

    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(),

        // Exercise display
        Expanded(child: _isResting ? _buildRestScreen() : _buildExerciseScreen(currentExercise)),

        // Controls
        _buildWorkoutControls(),
      ],
    );
  }

  Widget _buildWorkoutHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.nivel.cor.withOpacity(0.8), widget.nivel.cor.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconForMuscleGroup(widget.grupoMuscular), color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.grupoMuscular.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.nivel.displayName,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Treino focado em ${widget.grupoMuscular.toLowerCase()} para nível ${widget.nivel.displayName.toLowerCase()}',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(icon: Icons.timer, text: '${_exercises.length * 3} min'),
              const SizedBox(width: 12),
              _buildStatChip(icon: Icons.fitness_center, text: '${_exercises.length} exercícios'),
            ],
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

  Widget _buildStatChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(TrainSmartExercise exercise, int number) {
    return GestureDetector(
      onTap: () => _showExerciseDetail(exercise),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7D4FFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                      Text(
                        exercise.equipamento,
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
            if (exercise.descricao.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                exercise.descricao.length > 100
                    ? '${exercise.descricao.substring(0, 100)}...'
                    : exercise.descricao,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
            ],
            const SizedBox(height: 12),
            // Preview da imagem/GIF
            if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  child: Image.network(
                    exercise.gifUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade800,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: exercise.corNivel,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade800,
                        child: Center(
                          child: Icon(
                            exercise.iconeGrupoMuscular,
                            color: exercise.corNivel,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildExerciseInfo('3 séries'),
                const SizedBox(width: 16),
                _buildExerciseInfo('12-15 reps'),
                const SizedBox(width: 16),
                _buildExerciseInfo('30s descanso'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseDetail(TrainSmartExercise exercise) {
    print('🔍 Mostrando detalhes do exercício: ${exercise.nome}');
    print('🔍 Descrição: ${exercise.descricao}');
    print('🔍 GIF URL: ${exercise.gifUrl ?? "Nenhum"}');
    print('🔍 Grupo Muscular: ${exercise.grupoMuscular}');
    print('🔍 Equipamento: ${exercise.equipamento}');
    print('🔍 Nível: ${exercise.nivel ?? "Não informado"}');

    showDialog(
      context: context,
      builder: (context) => ExerciseDetailDialog(exercise: exercise),
    );
  }

  Widget _buildExerciseInfo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF7D4FFF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF7D4FFF),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _currentExerciseIndex / _exercises.length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercício ${_currentExerciseIndex + 1} de ${_exercises.length}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Série $_currentSet/$_totalSets',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7D4FFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseScreen(TrainSmartExercise exercise) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exercise.nome,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 200,
                      width: 200,
                      child: Image.network(
                        exercise.gifUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade800,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: exercise.corNivel,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: Center(
                              child: Icon(
                                exercise.iconeGrupoMuscular,
                                color: exercise.corNivel,
                                size: 64,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (exercise.descricao.isNotEmpty) ...[
                  Text(
                    exercise.descricao,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Color(0xFF7D4FFF), size: 64),
          const SizedBox(height: 20),
          Text(
            'Descanso',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$_restTime segundos',
            style: GoogleFonts.poppins(
              color: const Color(0xFF7D4FFF),
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutControls() {
    if (!_isWorkoutStarted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentExerciseIndex > 0) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _previousExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Anterior', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isResting ? null : _completeSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D4FFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isResting ? 'Descansando...' : 'Série Completa',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_currentExerciseIndex < _exercises.length - 1 || _currentSet < _totalSets) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Próximo', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_exercises.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isWorkoutStarted ? _completeWorkout : _startWorkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isWorkoutStarted ? Colors.green : const Color(0xFF7D4FFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Text(
            _isWorkoutStarted ? 'Finalizar Treino' : 'Iniciar Treino',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutStarted = true;
      _currentExerciseIndex = 0;
      _currentSet = 1;
    });
  }

  void _completeSet() {
    if (_currentSet < _totalSets) {
      setState(() {
        _currentSet++;
        _isResting = true;
        _restTime = 30;
      });

      // Simular timer de descanso
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isResting = false;
          });
        }
      });
    } else {
      _nextExercise();
    }
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _isResting = false;
      });
    } else {
      _completeWorkout();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSet = 1;
        _isResting = false;
      });
    }
  }

  void _completeWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Parabéns! 🎉',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Você completou o treino de ${widget.grupoMuscular}!',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Finalizar',
              style: GoogleFonts.poppins(
                color: const Color(0xFF7D4FFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareWorkout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Função de compartilhamento em desenvolvimento'),
        backgroundColor: Color(0xFF7D4FFF),
      ),
    );
  }
}

// Dialog para mostrar detalhes do exercício
class ExerciseDetailDialog extends StatelessWidget {
  final TrainSmartExercise exercise;

  const ExerciseDetailDialog({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header com nome do exercício
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: exercise.corNivel.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(exercise.iconeGrupoMuscular, color: exercise.corNivel, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      exercise.nome,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Conteúdo scrollável
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GIF do exercício
                    if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty) ...[
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            child: Image.network(
                              exercise.gifUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: exercise.corNivel,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: Center(
                                    child: Icon(
                                      exercise.iconeGrupoMuscular,
                                      color: exercise.corNivel,
                                      size: 64,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Informações do exercício
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip('Grupo: ${exercise.grupoMuscular}', Colors.purple),
                        _buildInfoChip('Equipamento: ${exercise.equipamento}', Colors.orange),
                        _buildInfoChip(
                          'Nível: ${exercise.nivel ?? "Iniciante"}',
                          exercise.corNivel,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Descrição
                    if (exercise.descricao.isNotEmpty) ...[
                      Text(
                        'Descrição',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.descricao,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Instruções padrão
                    Text(
                      'Instruções',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Realize 3 séries de 12-15 repetições\n'
                      '• Descanse 30-60 segundos entre as séries\n'
                      '• Mantenha a forma correta durante todo o movimento\n'
                      '• Controle a respiração durante o exercício',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.w500),
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
