import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/metric_tile.dart';
import '../services/auth_service.dart';
import '../services/health_service.dart';
import 'imc_page.dart';
import 'aulas_page.dart';
import 'profile_page.dart';
import 'heart_rate_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final HealthService _healthService = HealthService.instance;
  String userName = 'Usuário';
  int currentSteps = 0;
  double currentCalories = 0.0;
  int currentHeartRate = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeHealthService();
  }

  @override
  void dispose() {
    _healthService.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData != null && mounted) {
        setState(() {
          userName = userData['name'] ?? 'Usuário';
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _initializeHealthService() async {
    try {
      await _healthService.initialize();

      // Escutar mudanças nos passos
      _healthService.stepsStream.listen((steps) {
        if (mounted) {
          setState(() {
            currentSteps = steps;
          });
        }
      });

      // Escutar mudanças nas calorias
      _healthService.caloriesStream.listen((calories) {
        if (mounted) {
          setState(() {
            currentCalories = calories;
          });
        }
      });

      // Escutar mudanças nos batimentos
      _healthService.heartRateStream.listen((heartRate) {
        if (mounted) {
          setState(() {
            currentHeartRate = heartRate;
          });
        }
      });

      // Não iniciar monitoramento automático de batimentos
      // O sensor só será ativado quando o usuário acessar a página de medição
    } catch (e) {
      print('Erro ao inicializar serviço de saúde: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sair da conta', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja sair?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text('Sair', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Olá, $userName! 👋",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              "Vamos treinar hoje?",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            color: Colors.grey.shade900,
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Perfil', style: GoogleFonts.poppins(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Sair', style: GoogleFonts.poppins(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Métricas do dia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MetricTile(
                    title: "Passos",
                    value: currentSteps.toString(),
                    icon: Icons.directions_walk,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricTile(
                    title: "Calorias",
                    value: currentCalories.toStringAsFixed(0),
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HeartRatePage()),
                      );
                    },
                    child: MetricTile(
                      title: "Batimentos",
                      value: currentHeartRate > 0 ? currentHeartRate.toString() : "--",
                      icon: Icons.favorite,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Gráfico de progresso
            Text(
              "Progresso Semanal",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 1),
                        FlSpot(2, 4),
                        FlSpot(3, 2),
                        FlSpot(4, 5),
                        FlSpot(5, 3),
                        FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Ações rápidas
            Text(
              "Ações Rápidas",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: "Calcular IMC",
                    subtitle: "Monitore seu peso",
                    icon: Icons.monitor_weight,
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ImcPage())),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: "Treinos",
                    subtitle: "Aulas disponíveis",
                    icon: Icons.fitness_center,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AulasPage()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, color: const Color(0xFF7D4FFF), size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
