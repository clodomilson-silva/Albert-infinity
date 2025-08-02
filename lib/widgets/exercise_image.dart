import 'package:flutter/material.dart';
import '../models/exercise_models.dart';

class ExerciseImageWidget extends StatelessWidget {
  final Exercise exercise;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ExerciseImageWidget({
    super.key,
    required this.exercise,
    this.height = 120,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final borderRad = borderRadius ?? BorderRadius.circular(8);

    // Debug: Verificar se tem imagens
    print('🖼️ ExerciseImageWidget - Exercício: ${exercise.name}');
    print('🖼️ Número de imagens: ${exercise.images.length}');

    if (exercise.images.isNotEmpty) {
      for (int i = 0; i < exercise.images.length; i++) {
        print('🖼️ Imagem $i: ${exercise.images[i].image}');
      }
      return _buildImageWithFallbacks(borderRad);
    } else {
      print('🖼️ Nenhuma imagem encontrada, usando fallback');
    }

    return _buildFallback();
  }

  Widget _buildImageWithFallbacks(BorderRadius borderRad) {
    return Container(
      height: height,
      decoration: BoxDecoration(borderRadius: borderRad),
      child: ClipRRect(
        borderRadius: borderRad,
        child: _buildImageWidget(0, borderRad),
      ),
    );
  }

  Widget _buildImageWidget(int imageIndex, BorderRadius borderRad) {
    if (imageIndex >= exercise.images.length) {
      print('🖼️ Índice $imageIndex fora dos limites, usando fallback');
      return _buildFallback();
    }

    String imageUrl = exercise.images[imageIndex].image;
    print('🖼️ Tentando carregar imagem $imageIndex: $imageUrl');

    // Corrigir URL caso seja relativa
    if (!imageUrl.startsWith('http')) {
      imageUrl = 'https://wger.de$imageUrl';
      print('🖼️ URL corrigida para: $imageUrl');
    }

    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: fit,
      headers: const {'User-Agent': 'AlbertInfinity/1.0'},
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('🖼️ ✅ Imagem carregada com sucesso: $imageUrl');
          return child;
        }
        print(
          '🖼️ ⏳ Carregando imagem: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}',
        );
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: borderRad,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF7D4FFF),
                  strokeWidth: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Carregando...',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('🖼️ ❌ Erro ao carregar imagem $imageIndex: $error');
        print('🖼️ StackTrace: $stackTrace');

        // Tentar próxima imagem se disponível
        if (imageIndex + 1 < exercise.images.length) {
          print('🖼️ Tentando próxima imagem: ${imageIndex + 1}');
          return _buildImageWidget(imageIndex + 1, borderRad);
        }
        print('🖼️ Nenhuma imagem disponível, usando fallback');
        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade800, Colors.grey.shade900],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getExerciseIcon(), color: const Color(0xFF7D4FFF), size: 32),
            const SizedBox(height: 8),
            Text(
              'Exercício',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getExerciseIcon() {
    // Determinar ícone baseado no nome do exercício ou categoria
    final name = exercise.name.toLowerCase();

    if (name.contains('flexão') ||
        name.contains('push') ||
        name.contains('press')) {
      return Icons.fitness_center;
    } else if (name.contains('agachamento') ||
        name.contains('squat') ||
        name.contains('leg')) {
      return Icons.accessibility_new;
    } else if (name.contains('corrida') ||
        name.contains('run') ||
        name.contains('cardio')) {
      return Icons.directions_run;
    } else if (name.contains('abdominal') ||
        name.contains('core') ||
        name.contains('plank')) {
      return Icons.center_focus_strong;
    } else if (name.contains('bíceps') ||
        name.contains('tríceps') ||
        name.contains('arm')) {
      return Icons.sports_martial_arts;
    } else {
      return Icons.fitness_center;
    }
  }
}
