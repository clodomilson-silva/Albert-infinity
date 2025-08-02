import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/wger_api_service.dart';
import '../models/exercise_models.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final WgerApiService _apiService = WgerApiService.instance;
  bool _isLoading = false;
  String _testResult = '';
  List<Exercise> _exercises = [];
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Teste da API Wger",
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botões de teste
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testBasicConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D4FFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Testar Conexão',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testWorkoutGeneration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Gerar Treino',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Indicador de loading
            if (_isLoading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF7D4FFF)),
                    SizedBox(height: 16),
                    Text(
                      'Testando API...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],

            // Resultados do teste
            if (_testResult.isNotEmpty) ...[
              Text(
                'Resultado do Teste:',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _errorMessage.isEmpty
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _errorMessage.isEmpty ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  _testResult,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],

            // Lista de exercícios (se houver)
            if (_exercises.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Exercícios Encontrados (${_exercises.length}):',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (exercise.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              exercise.description.length > 100
                                  ? '${exercise.description.substring(0, 100)}...'
                                  : exercise.description,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip('ID: ${exercise.id}'),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                'Músculos: ${exercise.muscles.length}',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                'Imagens: ${exercise.images.length}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
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

  Future<void> _testBasicConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
      _exercises = [];
    });

    try {
      // Testar busca básica de exercícios
      final exercises = await _apiService.getExercises();

      setState(() {
        _isLoading = false;
        if (exercises.isNotEmpty) {
          _exercises = exercises
              .take(10)
              .toList(); // Mostrar apenas os primeiros 10
          _testResult =
              '''✅ CONEXÃO BEM-SUCEDIDA!

📊 Estatísticas:
• ${exercises.length} exercícios encontrados
• API respondendo normalmente
• Dados sendo processados corretamente

🔗 Endpoint testado:
https://wger.de/api/v2/exercise/

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
        } else {
          _testResult = '''⚠️ CONEXÃO OK, MAS SEM DADOS

A API respondeu, mas não retornou exercícios.
Isso pode ser temporário.''';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _testResult =
            '''❌ ERRO DE CONEXÃO

Detalhes do erro:
$e

🔧 Possíveis soluções:
• Verificar conexão com internet
• A API pode estar temporariamente indisponível
• Firewall pode estar bloqueando a requisição

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    }
  }

  Future<void> _testWorkoutGeneration() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
      _exercises = [];
    });

    try {
      // Testar geração de treino
      final workoutPlan = await _apiService.generateWorkoutPlan(
        level: WorkoutLevel.beginner,
        type: WorkoutType.strength,
        targetMuscleGroup: MuscleGroup.arms,
      );

      setState(() {
        _isLoading = false;
        _exercises = workoutPlan.exercises;
        _testResult =
            '''✅ TREINO GERADO COM SUCESSO!

📋 Detalhes do Treino:
• Nome: ${workoutPlan.name}
• Tipo: ${workoutPlan.type.displayName}
• Nível: ${workoutPlan.level.displayName}
• Duração: ${workoutPlan.estimatedDuration} minutos
• Exercícios: ${workoutPlan.exercises.length}

📝 Descrição:
${workoutPlan.description}

🎯 Músculos Alvo:
${workoutPlan.targetMuscles.join(', ')}

⏰ Gerado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _testResult =
            '''❌ ERRO NA GERAÇÃO DO TREINO

Detalhes do erro:
$e

🔧 Verificações:
• A conexão básica está funcionando?
• Os dados da API estão sendo processados corretamente?

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    }
  }
}
