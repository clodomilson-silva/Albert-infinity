import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Buscando Exercícios Populares com Nomes e Imagens ===');

  try {
    // Buscar exercícios mais populares/conhecidos
    List<int> popularExerciseIds = [
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, // IDs básicos
      20,
      25,
      30,
      35,
      40,
      45,
      50,
      55,
      60,
      65,
      70,
      75,
      80,
      85,
      90,
      95,
      100, // IDs médios
    ];

    List<Map<String, dynamic>> exercisesWithImages = [];

    for (int id in popularExerciseIds) {
      try {
        final response = await http.get(
          Uri.parse('https://wger.de/api/v2/exerciseinfo/$id/'),
          headers: {'Accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          final exercise = json.decode(response.body);

          // Verificar se tem imagens
          final imageResponse = await http.get(
            Uri.parse('https://wger.de/api/v2/exerciseimage/?exercise=$id'),
            headers: {'Accept': 'application/json'},
          );

          if (imageResponse.statusCode == 200) {
            final imageData = json.decode(imageResponse.body);
            final images = imageData['results'] as List;

            if (images.isNotEmpty && exercise['name'] != null) {
              exercisesWithImages.add({
                'id': id,
                'name': exercise['name'],
                'description': exercise['description'],
                'category': exercise['category'],
                'muscles': exercise['muscles'],
                'images': images,
                'language': exercise['language'],
              });

              print('\n--- Exercício $id ---');
              print('Nome: ${exercise['name']}');
              print('Idioma: ${exercise['language']}');
              print('Categoria: ${exercise['category']?['name']}');
              print('Imagens: ${images.length}');
              for (var image in images) {
                print('  - ${image['image']}');
              }
            }
          }
        }
      } catch (e) {
        // Ignore errors for individual exercises
      }
    }

    print('\n=== RESUMO ===');
    print(
      'Exercícios encontrados com nome e imagens: ${exercisesWithImages.length}',
    );

    // Mostrar os IDs para usar no serviço
    List<int> validIds = exercisesWithImages
        .map((e) => e['id'] as int)
        .toList();
    print('IDs válidos: $validIds');

    // Testar as primeiras 5 imagens
    print('\n=== TESTANDO PRIMEIRAS 5 IMAGENS ===');
    for (var exercise in exercisesWithImages.take(5)) {
      final images = exercise['images'] as List;
      for (var image in images.take(1)) {
        // Testar apenas a primeira imagem de cada
        final imageUrl = image['image'];
        try {
          final imageResponse = await http.head(Uri.parse(imageUrl));
          if (imageResponse.statusCode == 200) {
            print('✅ ${exercise['name']}: $imageUrl');
          } else {
            print(
              '❌ ${exercise['name']}: $imageUrl (${imageResponse.statusCode})',
            );
          }
        } catch (e) {
          print('❌ ${exercise['name']}: $imageUrl (erro: $e)');
        }
      }
    }
  } catch (e) {
    print('❌ Erro: $e');
  }
}
