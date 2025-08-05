import 'package:flutter/material.dart';
import '../models/trainsmart_models.dart';

class ExerciseImageWidget extends StatelessWidget {
  final TrainSmartExercise exercise;
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

    // Debug: Verificar se tem GIF
    print('🖼️ ExerciseImageWidget - Exercício: ${exercise.nome}');
    print('🖼️ GIF URL: ${exercise.gifUrl ?? "Nenhum"}');

    if (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty) {
      print('🖼️ Usando GIF: ${exercise.gifUrl}');
      return _buildGifImage(borderRad);
    } else {
      print('🖼️ Nenhum GIF encontrado, usando fallback');
      return _buildFallback();
    }
  }

  Widget _buildGifImage(BorderRadius borderRad) {
    return Container(
      height: height,
      decoration: BoxDecoration(borderRadius: borderRad),
      child: ClipRRect(
        borderRadius: borderRad,
        child: Image.network(
          exercise.gifUrl!,
          height: height,
          width: double.infinity,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('🖼️ ✅ GIF carregado com sucesso: ${exercise.gifUrl}');
              return child;
            }
            print(
              '🖼️ ⏳ Carregando GIF: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}',
            );
            return Container(
              height: height,
              decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: borderRad),
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
            print('🖼️ ❌ Erro ao carregar GIF: $error');
            print('🖼️ StackTrace: $stackTrace');
            return _buildFallback();
          },
        ),
      ),
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
            Icon(exercise.iconeGrupoMuscular, color: const Color(0xFF7D4FFF), size: 32),
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
}
