import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Buscando Todos os Exercícios com Imagens ===');

  try {
    List<Map<String, dynamic>> allExercisesWithImages = [];
    int currentPage = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      print('🔍 Processando página $currentPage...');

      final response = await http.get(
        Uri.parse(
          'https://wger.de/api/v2/exerciseinfo/?limit=50&offset=${(currentPage - 1) * 50}',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exercises = data['results'] as List;

        print('   Exercícios nesta página: ${exercises.length}');

        // Verificar cada exercício se tem imagens
        for (var exercise in exercises) {
          final images = exercise['images'] as List?;
          if (images != null && images.isNotEmpty) {
            allExercisesWithImages.add({
              'id': exercise['id'],
              'name': exercise['name'],
              'description': exercise['description'],
              'category': exercise['category'],
              'muscles': exercise['muscles'],
              'images': images,
              'language': exercise['language'],
            });
          }
        }

        // Verificar se há mais páginas
        hasMorePages = data['next'] != null;
        currentPage++;

        // Limitar a 10 páginas para não sobrecarregar
        if (currentPage > 10) {
          print('⚠️  Limitando busca a 10 páginas...');
          break;
        }
      } else {
        print('❌ Erro na página $currentPage: ${response.statusCode}');
        break;
      }

      // Pequeno delay para não sobrecarregar a API
      await Future.delayed(Duration(milliseconds: 100));
    }

    print('\n=== RESUMO FINAL ===');
    print(
      'Total de exercícios com imagens encontrados: ${allExercisesWithImages.length}',
    );

    // Mostrar alguns exemplos
    print('\n=== PRIMEIROS 10 EXERCÍCIOS ===');
    for (var exercise in allExercisesWithImages.take(10)) {
      print(
        'ID: ${exercise['id']} - Nome: ${exercise['name']} - Imagens: ${(exercise['images'] as List).length}',
      );
    }

    // Criar lista de IDs para usar no código
    List<int> exerciseIds = allExercisesWithImages
        .map((e) => e['id'] as int)
        .toList();
    print('\n=== IDs PARA USAR NO CÓDIGO ===');
    print('Total de IDs: ${exerciseIds.length}');
    print('Primeiros 20 IDs: ${exerciseIds.take(20).toList()}');

    // Agrupar por idioma
    Map<int, int> languageCount = {};
    for (var exercise in allExercisesWithImages) {
      final lang = exercise['language'];
      if (lang != null) {
        languageCount[lang] = (languageCount[lang] ?? 0) + 1;
      }
    }

    print('\n=== DISTRIBUIÇÃO POR IDIOMA ===');
    languageCount.forEach((langId, count) {
      print('Idioma $langId: $count exercícios');
    });
  } catch (e) {
    print('❌ Erro: $e');
  }
}
