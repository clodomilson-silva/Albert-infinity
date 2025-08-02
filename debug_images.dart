import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Debug de Imagens da API Wger ===');

  try {
    // Testar um exercício específico da API
    final response = await http.get(
      Uri.parse('https://wger.de/api/v2/exercise/?language=7&limit=10'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ API conectada com sucesso');
      print('Total de exercícios: ${data['count']}');

      final exercises = data['results'] as List;

      // Procurar exercícios com imagens
      int exercisesWithImages = 0;

      for (var exercise in exercises) {
        final images = exercise['images'] as List?;
        if (images != null && images.isNotEmpty) {
          exercisesWithImages++;
          print('\n--- Exercício ${exercise['id']} ---');

          if (exercise['translations'] != null &&
              exercise['translations'].isNotEmpty) {
            final translation = exercise['translations'][0];
            print('Nome: ${translation['name'] ?? 'Sem nome'}');
          }

          print('Número de imagens: ${images.length}');

          for (int i = 0; i < images.length; i++) {
            final imageData = images[i];
            print('  Imagem ${i + 1}:');
            print('    ID: ${imageData['id']}');
            print('    URL: ${imageData['image']}');
            print('    Principal: ${imageData['is_main']}');

            // Testar se a URL está acessível
            String imageUrl = imageData['image'];
            if (!imageUrl.startsWith('http')) {
              imageUrl = 'https://wger.de$imageUrl';
            }
            print('    URL completa: $imageUrl');

            // Tentar fazer HEAD request para verificar se existe
            try {
              final imageResponse = await http.head(Uri.parse(imageUrl));
              print('    Status HTTP: ${imageResponse.statusCode}');
              print(
                '    Content-Type: ${imageResponse.headers['content-type']}',
              );
            } catch (e) {
              print('    ❌ Erro ao acessar: $e');
            }
          }

          if (exercisesWithImages >= 3) break; // Testar apenas 3 exercícios
        }
      }

      print('\n📊 Resumo:');
      print('Exercícios com imagens: $exercisesWithImages');
      print('Total testado: ${exercises.length}');
    } else {
      print('❌ Erro na API: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Erro na conexão: $e');
  }
}
