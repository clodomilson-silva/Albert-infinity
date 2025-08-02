import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Mapeando Exercícios com Imagens ===');

  try {
    // Primeiro buscar todas as imagens disponíveis
    final imagesResponse = await http.get(
      Uri.parse('https://wger.de/api/v2/exerciseimage/?limit=20'),
      headers: {'Accept': 'application/json'},
    );

    if (imagesResponse.statusCode == 200) {
      final imagesData = json.decode(imagesResponse.body);
      final images = imagesData['results'] as List;

      print('✅ Encontradas ${images.length} imagens');

      // Mapear quais exercícios têm imagens
      Set<int> exerciseIdsWithImages = {};
      for (var img in images) {
        exerciseIdsWithImages.add(img['exercise'] as int);
      }

      print('Exercícios com imagens: ${exerciseIdsWithImages.toList()}');

      // Agora buscar exercícios em português que tenham imagens
      final exercisesResponse = await http.get(
        Uri.parse('https://wger.de/api/v2/exerciseinfo/?language=7&limit=100'),
        headers: {'Accept': 'application/json'},
      );

      if (exercisesResponse.statusCode == 200) {
        final exercisesData = json.decode(exercisesResponse.body);
        final exercises = exercisesData['results'] as List;

        print('\n=== Exercícios em Português com Imagens ===');

        int found = 0;
        for (var exercise in exercises) {
          if (exerciseIdsWithImages.contains(exercise['id'])) {
            found++;
            print('\n✅ Exercício ID: ${exercise['id']}');

            if (exercise['translations'] != null &&
                exercise['translations'].isNotEmpty) {
              final translation = exercise['translations'][0];
              print('   Nome: ${translation['name']}');
            }

            // Buscar imagens específicas
            final specificImagesResponse = await http.get(
              Uri.parse(
                'https://wger.de/api/v2/exerciseimage/?exercise=${exercise['id']}',
              ),
              headers: {'Accept': 'application/json'},
            );

            if (specificImagesResponse.statusCode == 200) {
              final specificImagesData = json.decode(
                specificImagesResponse.body,
              );
              final specificImages = specificImagesData['results'] as List;

              print('   Imagens (${specificImages.length}):');
              for (var img in specificImages) {
                print('     - ${img['image']}');
              }
            }

            if (found >= 5) break; // Mostrar apenas 5 exemplos
          }
        }

        print('\n📊 Total de exercícios portugueses com imagens: $found');
      }
    }
  } catch (e) {
    print('❌ Erro: $e');
  }
}
