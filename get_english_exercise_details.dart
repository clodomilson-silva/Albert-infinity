import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Detalhes dos Exercícios em Inglês com Imagens ===');

  List<int> exerciseIds = [1022, 822, 828, 927, 958, 50, 984, 988, 959];

  for (int id in exerciseIds) {
    try {
      final response = await http.get(
        Uri.parse('https://wger.de/api/v2/exerciseinfo/$id/'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final exercise = json.decode(response.body);

        print('\n--- Exercício $id ---');
        print('Nome: ${exercise['name']}');
        print(
          'Descrição: ${exercise['description']?.toString().replaceAll(RegExp(r'<[^>]*>'), '').substring(0, 100) ?? 'N/A'}...',
        );
        print('Categoria: ${exercise['category']}');
        print('Músculos: ${exercise['muscles']}');

        // Buscar imagens
        final imageResponse = await http.get(
          Uri.parse('https://wger.de/api/v2/exerciseimage/?exercise=$id'),
          headers: {'Accept': 'application/json'},
        );

        if (imageResponse.statusCode == 200) {
          final imageData = json.decode(imageResponse.body);
          final images = imageData['results'] as List;
          print('Imagens: ${images.length}');
          for (var image in images) {
            print('  - ${image['image']}');
          }
        }
      }
    } catch (e) {
      print('❌ Erro ao buscar exercício $id: $e');
    }
  }
}
