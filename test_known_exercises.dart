import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Testando Exercícios Conhecidos que Funcionaram ===');

  // Estes são os IDs que sabemos que funcionaram no português
  List<int> knownWorkingIds = [
    74,
    81,
    83,
    91,
    92,
    95, // IDs que sabemos que têm imagens dos testes anteriores
    127, 129, 93, 88, // IDs das imagens que vimos carregando
  ];

  List<Map<String, dynamic>> validExercises = [];

  for (int id in knownWorkingIds) {
    try {
      // Tentar em inglês primeiro
      final response = await http.get(
        Uri.parse('https://wger.de/api/v2/exerciseinfo/$id/?language=2'),
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

          if (images.isNotEmpty) {
            validExercises.add({
              'id': id,
              'name': exercise['name'] ?? 'Exercise $id',
              'description': exercise['description'],
              'category': exercise['category'],
              'images': images,
              'language': exercise['language'],
            });

            print('\n--- Exercício $id ---');
            print('Nome: ${exercise['name'] ?? 'Exercise $id'}');
            print('Idioma: ${exercise['language']}');
            print('Categoria: ${exercise['category']?['name'] ?? 'N/A'}');
            print('Imagens: ${images.length}');

            // Testar primeira imagem
            final firstImage = images.first['image'];
            try {
              final imageTest = await http.head(Uri.parse(firstImage));
              if (imageTest.statusCode == 200) {
                print('✅ Primeira imagem acessível: $firstImage');
              } else {
                print('❌ Primeira imagem não acessível: $firstImage');
              }
            } catch (e) {
              print('❌ Erro ao testar imagem: $e');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Erro ao processar exercício $id: $e');
    }
  }

  print('\n=== RESUMO FINAL ===');
  print('Exercícios válidos encontrados: ${validExercises.length}');

  if (validExercises.isNotEmpty) {
    List<int> finalIds = validExercises.map((e) => e['id'] as int).toList();
    print('IDs para usar no serviço: $finalIds');

    print('\n=== LISTA PARA COPIAR NO CÓDIGO ===');
    print('List<int> exerciseIdsWithImages = $finalIds;');
  }
}
