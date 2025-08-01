import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AulasPage extends StatelessWidget {
  const AulasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Treinos & Aulas",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Seu Progresso",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildProgressStat("Treinos\nConcluídos", "12"),
                      _buildProgressStat("Esta\nSemana", "3"),
                      _buildProgressStat("Tempo\nTotal", "4h 30m"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Seção Gratuitos
            Row(
              children: [
                const Icon(Icons.lock_open, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Treinos Gratuitos",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            _buildWorkoutCard(
              title: "Treino para Iniciantes",
              subtitle: "Exercícios básicos • 15 min",
              difficulty: "Iniciante",
              difficultyColor: Colors.green,
              icon: Icons.accessibility_new,
              onTap: () => _showWorkoutDetails(context, "Treino para Iniciantes"),
            ),
            
            _buildWorkoutCard(
              title: "Cardio Matinal",
              subtitle: "Aquecimento e alongamento • 10 min",
              difficulty: "Fácil",
              difficultyColor: Colors.blue,
              icon: Icons.directions_run,
              onTap: () => _showWorkoutDetails(context, "Cardio Matinal"),
            ),

            _buildWorkoutCard(
              title: "Yoga Relaxante",
              subtitle: "Respiração e flexibilidade • 20 min",
              difficulty: "Iniciante",
              difficultyColor: Colors.green,
              icon: Icons.self_improvement,
              onTap: () => _showWorkoutDetails(context, "Yoga Relaxante"),
            ),

            const SizedBox(height: 30),

            // Seção Premium
            Row(
              children: [
                const Icon(Icons.diamond, color: Color(0xFFFFD700), size: 20),
                const SizedBox(width: 8),
                Text(
                  "Treinos Premium",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            _buildWorkoutCard(
              title: "Hipertrofia Avançada",
              subtitle: "Ganho de massa muscular • 45 min",
              difficulty: "Avançado",
              difficultyColor: Colors.red,
              icon: Icons.fitness_center,
              isPremium: true,
              onTap: () => _showPremiumDialog(context),
            ),

            _buildWorkoutCard(
              title: "HIIT Intenso",
              subtitle: "Queima de gordura • 30 min",
              difficulty: "Intermediário",
              difficultyColor: Colors.orange,
              icon: Icons.flash_on,
              isPremium: true,
              onTap: () => _showPremiumDialog(context),
            ),

            _buildWorkoutCard(
              title: "Plano Alimentar",
              subtitle: "Nutrição personalizada • 7 dias",
              difficulty: "Todos",
              difficultyColor: Colors.purple,
              icon: Icons.restaurant_menu,
              isPremium: true,
              onTap: () => _showPremiumDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWorkoutCard({
    required String title,
    required String subtitle,
    required String difficulty,
    required Color difficultyColor,
    required IconData icon,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7D4FFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF7D4FFF), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isPremium) ...[
                          const Icon(Icons.diamond, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 4),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: difficultyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            difficulty,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: difficultyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, String workoutTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutTitle,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Descrição do treino e exercícios inclusos...",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D4FFF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Iniciando treino: $workoutTitle"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text(
                  "Iniciar Treino",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.diamond, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Text(
              "Premium",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          "Este conteúdo está disponível apenas para assinantes Premium. Assine agora e tenha acesso completo!",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Redirecionando para assinatura..."),
                  backgroundColor: Color(0xFFFFD700),
                ),
              );
            },
            child: Text(
              "Assinar",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
