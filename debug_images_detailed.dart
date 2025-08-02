import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Debug de Imagens Separadas da API Wger ===');

  try {
    // Primeiro, pegar alguns exercícios
    final exerciseResponse = await http.get(
      Uri.parse('https://wger.de/api/v2/exercise/?language=7&limit=5'),
      headers: {'Accept': 'application/json'},
    );

    if (exerciseResponse.statusCode == 200) {
      final exerciseData = json.decode(exerciseResponse.body);
      final exercises = exerciseData['results'] as List;

      print('✅ Exercícios obtidos: ${exercises.length}');

      for (var exercise in exercises) {
        final exerciseId = exercise['id'];
        print('\n--- Testando exercício ID: $exerciseId ---');

        if (exercise['translations'] != null &&
            exercise['translations'].isNotEmpty) {
          final translation = exercise['translations'][0];
          print('Nome: ${translation['name'] ?? 'Sem nome'}');
        }

        // Testar endpoint de imagens para este exercício
        try {
          final imageResponse = await http.get(
            Uri.parse(
              'https://wger.de/api/v2/exerciseimage/?exercise=$exerciseId&limit=10',
            ),
            headers: {'Accept': 'application/json'},
          );

          if (imageResponse.statusCode == 200) {
            final imageData = json.decode(imageResponse.body);
            final images = imageData['results'] as List;

            print('Imagens encontradas: ${images.length}');

            if (images.isNotEmpty) {
              for (int i = 0; i < images.length && i < 3; i++) {
                final img = images[i];
                print('  Imagem ${i + 1}:');
                print('    ID: ${img['id']}');
                print('    URL: ${img['image']}');
                print('    Principal: ${img['is_main']}');

                // Testar URL completa
                String imageUrl = img['image'];
                if (!imageUrl.startsWith('http')) {
                  imageUrl = 'https://wger.de${img['image']}';
                }
                print('    URL completa: $imageUrl');

                // Verificar se existe
                try {
                  final testResponse = await http.head(Uri.parse(imageUrl));
                  print('    ✅ Status: ${testResponse.statusCode}');
                  if (testResponse.statusCode == 200) {
                    print('    ✅ Imagem acessível!');
                  }
                } catch (e) {
                  print('    ❌ Erro: $e');
                }
              }
              break; // Parar no primeiro exercício com imagens
            }
          } else {
            print('Erro ao buscar imagens: ${imageResponse.statusCode}');
          }
        } catch (e) {
          print('Erro na requisição de imagens: $e');
        }
      }
    } else {
      print('❌ Erro na API de exercícios: ${exerciseResponse.statusCode}');
    }

    // Testar endpoint geral de imagens
    print('\n=== Testando endpoint geral de imagens ===');
    try {
      final allImagesResponse = await http.get(
        Uri.parse('https://wger.de/api/v2/exerciseimage/?limit=5'),
        headers: {'Accept': 'application/json'},
      );

      if (allImagesResponse.statusCode == 200) {
        final allImagesData = json.decode(allImagesResponse.body);
        print('Total de imagens no sistema: ${allImagesData['count']}');

        final images = allImagesData['results'] as List;
        print('Primeiras 5 imagens:');

        for (var img in images) {
          print(
            '  ID: ${img['id']} | Exercício: ${img['exercise']} | URL: ${img['image']}',
          );
        }
      }
    } catch (e) {
      print('Erro ao testar endpoint geral: $e');
    }
  } catch (e) {
    print('❌ Erro geral: $e');
  }
}
