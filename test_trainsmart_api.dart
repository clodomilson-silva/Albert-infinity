import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    print('🧪 Testando API TrainSmart...');

    final response = await http.get(
      Uri.parse('https://trainsmart-api.onrender.com/exercicios?limit=2'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Status: ${response.statusCode}');
    print('Headers: ${response.headers}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Dados recebidos:');
      print(jsonEncode(data, toEncodable: (e) => e.toString()));

      if (data is List && data.isNotEmpty) {
        final firstExercise = data[0];
        print('\n🎯 Primeiro exercício:');
        print('ID: ${firstExercise['id']}');
        print('Nome: ${firstExercise['nome']}');
        print('Descrição: ${firstExercise['descricao']}');
        print('Grupo Muscular: ${firstExercise['grupo_muscular']}');
        print('Equipamento: ${firstExercise['equipamento']}');
        print('Nível: ${firstExercise['nivel']}');
        print('GIF URL: ${firstExercise['gif_url']}');
      }
    } else {
      print('❌ Erro: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Exceção: $e');
  }
}
