import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== Teste da API Wger com Português ===');

  try {
    // Testar a API com português (ID: 7)
    final response = await http.get(
      Uri.parse('https://wger.de/api/v2/exercise/?language=7&limit=5'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Status: SUCCESS');
      print('Total de exercícios: ${data['count']}');
      print('\nPrimeiros 5 exercícios:');

      final exercises = data['results'] as List;
      for (int i = 0; i < exercises.length && i < 5; i++) {
        final exercise = exercises[i];
        print('${i + 1}. ID: ${exercise['id']}');
        print(
          '   Exercício completo: ${exercise.toString().substring(0, 200)}...',
        );

        if (exercise['translations'] != null &&
            exercise['translations'].isNotEmpty) {
          final translation = exercise['translations'][0];
          print('   Nome: ${translation['name']}');
          String description = translation['description'] ?? '';
          // Remover HTML tags
          description = description.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          if (description.length > 100) {
            description = description.substring(0, 100) + '...';
          }
          print('   Descrição: $description');
        } else {
          print('   Sem traduções disponíveis');
        }
        print('');
      }
    } else {
      print('Erro: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Erro na conexão: $e');
  }
}
