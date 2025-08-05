import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trainsmart_models.dart';
import '../services/trainsmart_api_service.dart';

class AulasPage extends StatefulWidget {
  const AulasPage({super.key});

  @override
  State<AulasPage> createState() => _AulasPageState();
}

class _AulasPageState extends State<AulasPage> {
  final TrainSmartApiService _apiService = TrainSmartApiService.instance;
  List<String> _gruposMusculares = [];
  Map<String, List<TrainSmartExercise>> _exerciciosPorGrupo = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Carregar grupos musculares
      final grupos = await _apiService.getGruposMusculares();

      // Carregar exercícios e organizá-los por grupo
      final allExercises = await _apiService.getExercises(limit: 100);

      Map<String, List<TrainSmartExercise>> exercisesByGroup = {};

      for (String grupo in grupos) {
        exercisesByGroup[grupo] = allExercises
            .where((exercise) => exercise.grupoMuscular.toLowerCase() == grupo.toLowerCase())
            .take(6) // Limitar a 6 exercícios por grupo para não sobrecarregar
            .toList();
      }

      setState(() {
        _gruposMusculares = grupos;
        _exerciciosPorGrupo = exercisesByGroup;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados: $e';
      });
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
          "Treinos & Aulas",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Navegação temporariamente desabilitada
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Funcionalidade em desenvolvimento')));
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _buildContent(),
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
            'Erro ao carregar dados',
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
            onPressed: _loadData,
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

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com estatísticas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7D4FFF).withOpacity(0.8),
                  const Color(0xFFBA9CFF).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Atendimento personalizado",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Exercícios organizados por grupo muscular com demonstrações em GIF",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navegação temporariamente desabilitada
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF7D4FFF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.star, size: 20),
                        label: Text(
                          "Explorar Recursos Premium",
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Seções por grupo muscular
          ..._gruposMusculares.map((grupo) => _buildGrupoMuscularSection(grupo)),
        ],
      ),
    );
  }

  Widget _buildGrupoMuscularSection(String grupoMuscular) {
    final exercicios = _exerciciosPorGrupo[grupoMuscular] ?? [];

    if (exercicios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getColorForMuscleGroup(grupoMuscular).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForMuscleGroup(grupoMuscular),
                    color: _getColorForMuscleGroup(grupoMuscular),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  grupoMuscular.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _showAllExercisesForGroup(grupoMuscular),
              child: Text(
                "Ver todos",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF7D4FFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Lista horizontal de exercícios
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: exercicios.length,
            itemBuilder: (context, index) {
              final exercicio = exercicios[index];
              return _buildExerciseCard(exercicio);
            },
          ),
        ),

        const SizedBox(height: 32),
      ],
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
      barrierDismissible: true, // Permite fechar clicando fora
      builder: (context) => ExerciseDetailDialog(exercise: exercise),
    );
  }

  void _showAllExercisesForGroup(String grupoMuscular) async {
    try {
      // Buscar todos os exercícios do grupo
      final allExercises = await _apiService.getExercises(limit: 100);
      final exercisesInGroup = allExercises
          .where((exercise) => exercise.grupoMuscular.toLowerCase() == grupoMuscular.toLowerCase())
          .toList();

      if (exercisesInGroup.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Nenhum exercício encontrado para $grupoMuscular')));
        return;
      }

      // Mostrar dialog com todos os exercícios
      showDialog(
        context: context,
        builder: (context) => AllExercisesDialog(
          grupoMuscular: grupoMuscular,
          exercises: exercisesInGroup,
          onExerciseTap: _showExerciseDetail,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar exercícios: $e')));
    }
  }

  Widget _buildExerciseCard(TrainSmartExercise exercicio) {
    return GestureDetector(
      onTap: () => _showExerciseDetail(exercicio),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GIF do exercício
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 150,
                width: double.infinity,
                child: exercicio.gifUrl != null && exercicio.gifUrl!.isNotEmpty
                    ? Image.network(
                        exercicio.gifUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade800,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: exercicio.corNivel,
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
                                exercicio.iconeGrupoMuscular,
                                color: exercicio.corNivel,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade800,
                        child: Center(
                          child: Icon(
                            exercicio.iconeGrupoMuscular,
                            color: exercicio.corNivel,
                            size: 48,
                          ),
                        ),
                      ),
              ),
            ),

            // Informações do exercício
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        exercicio.nome,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        exercicio.equipamento,
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: exercicio.corNivel,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exercicio.nivel ?? "Iniciante",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
      case 'glúteos':
      case 'gluteos':
        return Icons.crop_square;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getColorForMuscleGroup(String grupo) {
    switch (grupo.toLowerCase()) {
      case 'peito':
        return Colors.red;
      case 'costas':
        return Colors.blue;
      case 'pernas':
        return Colors.green;
      case 'braços':
      case 'bracos':
        return Colors.orange;
      case 'ombros':
        return Colors.purple;
      case 'abdômen':
      case 'abdomen':
        return Colors.yellow;
      case 'glúteos':
      case 'gluteos':
        return Colors.pink;
      default:
        return const Color(0xFF7D4FFF);
    }
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
                    // GIF do exercício - MAIOR
                    if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty) ...[
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 300, // GIF maior como solicitado
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

// Dialog para mostrar todos os exercícios de um grupo muscular
class AllExercisesDialog extends StatelessWidget {
  final String grupoMuscular;
  final List<TrainSmartExercise> exercises;
  final Function(TrainSmartExercise) onExerciseTap;

  const AllExercisesDialog({
    super.key,
    required this.grupoMuscular,
    required this.exercises,
    required this.onExerciseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getColorForMuscleGroup(grupoMuscular).withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForMuscleGroup(grupoMuscular),
                    color: _getColorForMuscleGroup(grupoMuscular),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grupoMuscular.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${exercises.length} exercícios disponíveis',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Lista de exercícios
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Fechar este dialog
                      onExerciseTap(exercise); // Mostrar detalhes
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // GIF do exercício
                          SizedBox(
                            height: 120,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Container(
                                width: double.infinity,
                                child: exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty
                                    ? Image.network(
                                        exercise.gifUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.grey.shade700,
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
                                            color: Colors.grey.shade700,
                                            child: Center(
                                              child: Icon(
                                                exercise.iconeGrupoMuscular,
                                                color: exercise.corNivel,
                                                size: 32,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey.shade700,
                                        child: Center(
                                          child: Icon(
                                            exercise.iconeGrupoMuscular,
                                            color: exercise.corNivel,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          // Informações do exercício
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      exercise.nome,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      exercise.equipamento,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: exercise.corNivel,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      exercise.nivel ?? "Iniciante",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
      case 'glúteos':
      case 'gluteos':
        return Icons.crop_square;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getColorForMuscleGroup(String grupo) {
    switch (grupo.toLowerCase()) {
      case 'peito':
        return Colors.red;
      case 'costas':
        return Colors.blue;
      case 'pernas':
        return Colors.green;
      case 'braços':
      case 'bracos':
        return Colors.orange;
      case 'ombros':
        return Colors.purple;
      case 'abdômen':
      case 'abdomen':
        return Colors.yellow;
      case 'glúteos':
      case 'gluteos':
        return Colors.pink;
      default:
        return const Color(0xFF7D4FFF);
    }
  }
}
