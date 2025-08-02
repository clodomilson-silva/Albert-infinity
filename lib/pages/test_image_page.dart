import 'package:flutter/material.dart';

class TestImageWidget extends StatelessWidget {
  const TestImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Images - English Exercises'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Testing English Exercise Images Loading',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Teste 1: Imagem conhecida que existe
            _buildTestImage(
              'Biceps Curl 1',
              'https://wger.de/media/exercise-images/81/Biceps-curl-1.png',
            ),

            const SizedBox(height: 20),

            // Teste 2: Outra imagem conhecida
            _buildTestImage(
              'Biceps Curl 2',
              'https://wger.de/media/exercise-images/81/Biceps-curl-2.png',
            ),

            const SizedBox(height: 20),

            // Teste 3: Imagem que não existe (para testar fallback)
            _buildTestImage(
              'Imagem Inexistente',
              'https://wger.de/media/exercise-images/999/nonexistent.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestImage(String title, String url) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            url,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                headers: const {'User-Agent': 'AlbertInfinity/1.0'},
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade800,
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
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Carregando...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Erro ao carregar $url: $error');
                  return Container(
                    color: Colors.red.shade900,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.white, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Erro ao carregar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
