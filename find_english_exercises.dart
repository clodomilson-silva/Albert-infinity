import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Buscando Exercícios em Inglês com Imagens ===');

  try {
    // Buscar exercícios em inglês (language=2)
    final response = await http.get(
      Uri.parse('https://wger.de/api/v2/exerciseinfo/?language=2&limit=50'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ API conectada com sucesso');
      print('Total de exercícios em inglês: ${data['count']}');

      final exercises = data['results'] as List;
      List<int> exercisesWithImages = [];

      // Procurar exercícios com imagens
      for (var exercise in exercises) {
        final images = exercise['images'] as List?;
        if (images != null && images.isNotEmpty) {
          exercisesWithImages.add(exercise['id']);
          print('\n--- Exercício ${exercise['id']} ---');
          print('Nome: ${exercise['name']}');
          print('Imagens: ${images.length}');

          // Mostrar URLs das imagens
          for (var image in images) {
            print('  - ${image['image']}');
          }
        }
      }

      print('\n=== RESUMO ===');
      print('Exercícios com imagens em inglês: ${exercisesWithImages.length}');
      print('IDs: $exercisesWithImages');

      // Vamos testar os primeiros 10 IDs para ver se as imagens carregam
      print('\n=== TESTANDO PRIMEIROS 10 IDs ===');
      for (int id in exercisesWithImages.take(10)) {
        await testExerciseImages(id);
      }
    } else {
      print('❌ Erro na API: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erro: $e');
  }
}

Future<void> testExerciseImages(int exerciseId) async {
  try {
    final response = await http.get(
      Uri.parse('https://wger.de/api/v2/exerciseimage/?exercise=$exerciseId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final images = data['results'] as List;

      print('\n🔍 Exercício $exerciseId:');
      print('   Imagens disponíveis: ${images.length}');

      for (var image in images) {
        final imageUrl = image['image'];
        print('   📸 $imageUrl');

        // Testar se a imagem existe fazendo um HEAD request
        try {
          final imageResponse = await http.head(Uri.parse(imageUrl));
          if (imageResponse.statusCode == 200) {
            print('   ✅ Imagem acessível');
          } else {
            print('   ❌ Imagem não acessível (${imageResponse.statusCode})');
          }
        } catch (e) {
          print('   ❌ Erro ao acessar imagem: $e');
        }
      }
    }
  } catch (e) {
    print('❌ Erro ao testar exercício $exerciseId: $e');
  }
}
