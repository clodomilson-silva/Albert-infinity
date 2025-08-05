import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/trainsmart_api_service.dart';
import '../models/trainsmart_models.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final TrainSmartApiService _apiService = TrainSmartApiService.instance;
  bool _isLoading = false;
  String _testResult = '';
  List<TrainSmartExercise> _exercises = [];
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Teste da TrainSmart API",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botões de teste
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTestButton('Health Check', Colors.blue, _testHealthCheck),
                _buildTestButton('Listar Exercícios', const Color(0xFF7D4FFF), _testListExercises),
                _buildTestButton('Grupos Musculares', Colors.green, _testGetGruposMusculares),
                _buildTestButton('Equipamentos', Colors.orange, _testGetEquipamentos),
              ],
            ),

            const SizedBox(height: 20),

            // Status da autenticação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _apiService.isAuthenticated
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _apiService.isAuthenticated ? Colors.green : Colors.grey),
              ),
              child: Row(
                children: [
                  Icon(
                    _apiService.isAuthenticated ? Icons.lock_open : Icons.lock,
                    color: _apiService.isAuthenticated ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _apiService.isAuthenticated
                        ? 'Autenticado'
                        : 'Não autenticado (acesso público)',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Indicador de loading
            if (_isLoading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF7D4FFF)),
                    SizedBox(height: 16),
                    Text('Testando API...', style: TextStyle(color: Colors.white)),
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
                  border: Border.all(color: _errorMessage.isEmpty ? Colors.green : Colors.red),
                ),
                child: Text(
                  _testResult,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.4),
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
              SizedBox(
                height: 400, // Altura fixa para evitar overflow
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
                          Row(
                            children: [
                              Icon(exercise.iconeGrupoMuscular, color: exercise.corNivel, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  exercise.nome,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (exercise.descricao.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              exercise.descricao.length > 100
                                  ? '${exercise.descricao.substring(0, 100)}...'
                                  : exercise.descricao,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          // Mostrar GIF se disponível
                          if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Demonstração (GIF):',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    exercise.gifUrl!,
                                    height: 180,
                                    width: 180,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 180,
                                        width: 180,
                                        color: Colors.grey.shade800,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const CircularProgressIndicator(
                                                color: Color(0xFF7D4FFF),
                                                strokeWidth: 2,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Carregando\nGIF...',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 180,
                                        width: 180,
                                        color: Colors.grey.shade800,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                exercise.iconeGrupoMuscular,
                                                color: const Color(0xFF7D4FFF),
                                                size: 32,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'GIF Indisponível',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'ID: ${exercise.id.toString().padLeft(4, '0')}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                  fontSize: 8,
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
                            const SizedBox(height: 8),
                          ],

                          // Chips informativos
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildInfoChip('ID: ${exercise.id}', Colors.blue),
                              _buildInfoChip(exercise.grupoMuscular, Colors.purple),
                              _buildInfoChip(exercise.equipamento, Colors.orange),
                              _buildInfoChip(exercise.nivel ?? "Iniciante", exercise.corNivel),
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

  Widget _buildTestButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
      _exercises = [];
    });

    try {
      final healthStatus = await _apiService.getHealthStatus();

      setState(() {
        _isLoading = false;
        _testResult =
            '''✅ API TRAINSMART FUNCIONANDO!

🌐 Status da API: ${healthStatus.status}
🕒 Timestamp: ${healthStatus.timestamp.toString().substring(0, 19)}
${healthStatus.isHealthy ? '💚' : '❤️'} Estado: ${healthStatus.isHealthy ? 'Saudável' : 'Com problemas'}

🔗 Base URL: ${TrainSmartApiService.baseUrl}
🔧 Cache Stats: ${_apiService.getCacheStats()}

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _testResult =
            '''❌ ERRO NO HEALTH CHECK

Detalhes do erro:
$e

🔧 Possíveis soluções:
• Verificar conexão com internet
• A API pode estar temporariamente indisponível
• Verificar se a URL da API está correta

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    }
  }

  Future<void> _testListExercises() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
      _exercises = [];
    });

    try {
      final exercises = await _apiService.getExercises(limit: 20);

      setState(() {
        _isLoading = false;
        _exercises = exercises;
        _testResult =
            '''✅ EXERCÍCIOS CARREGADOS COM SUCESSO!

📊 Estatísticas:
• ${exercises.length} exercícios encontrados
• TrainSmart API respondendo normalmente
• Dados sendo processados corretamente
• GIFs incluídos quando disponíveis

🔗 Endpoint testado: ${TrainSmartApiService.baseUrl}/exercicios

📋 Grupos musculares encontrados:
${exercises.map((e) => e.grupoMuscular).toSet().join(', ')}

💪 Níveis encontrados:
${exercises.map((e) => e.nivel).toSet().join(', ')}

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _testResult =
            '''❌ ERRO AO CARREGAR EXERCÍCIOS

Detalhes do erro:
$e

🔧 Verificações:
• A API está funcionando? (teste o Health Check primeiro)
• Problemas de conectividade?

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    }
  }

  Future<void> _testGetGruposMusculares() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
      _exercises = [];
    });

    try {
      final grupos = await _apiService.getGruposMusculares();

      setState(() {
        _isLoading = false;
        _testResult =
            '''✅ GRUPOS MUSCULARES CARREGADOS!

💪 Total de grupos encontrados: ${grupos.length}

📋 Lista completa:
${grupos.map((grupo) => '• $grupo').join('\n')}

🔗 Endpoint testado: ${TrainSmartApiService.baseUrl}/exercicios/grupos-musculares

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _testResult =
            '''❌ ERRO AO CARREGAR GRUPOS MUSCULARES

Detalhes do erro:
$e

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    }
  }

  Future<void> _testGetEquipamentos() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
      _exercises = [];
    });

    try {
      final equipamentos = await _apiService.getEquipamentos();

      setState(() {
        _isLoading = false;
        _testResult =
            '''✅ EQUIPAMENTOS CARREGADOS!

🏋️ Total de equipamentos encontrados: ${equipamentos.length}

📋 Lista completa:
${equipamentos.map((equipamento) => '• $equipamento').join('\n')}

🔗 Endpoint testado: ${TrainSmartApiService.baseUrl}/exercicios/equipamentos

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _testResult =
            '''❌ ERRO AO CARREGAR EQUIPAMENTOS

Detalhes do erro:
$e

⏰ Teste realizado em: ${DateTime.now().toString().substring(0, 19)}''';
      });
    }
  }
}
