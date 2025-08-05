import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'workout_explorer_page.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkoutExplorerPage()),
              );
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
                  "TrainSmart API",
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WorkoutExplorerPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF7D4FFF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.explore, size: 20),
                        label: Text(
                          "Explorar Todos",
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkoutExplorerPage(initialLevel: NivelExercicio.iniciante),
                  ),
                );
              },
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

  Widget _buildExerciseCard(TrainSmartExercise exercicio) {
    return Container(
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
