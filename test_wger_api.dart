import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testWgerApi() async {
  print('🔗 Testando conexão com API Wger...');

  try {
    final response = await http.get(
      Uri.parse('https://wger.de/api/v2/exerciseinfo/?language=2&limit=5'),
      headers: {'Accept': 'application/json'},
    );

    print('📊 Status Code: ${response.statusCode}');
    print('📏 Content Length: ${response.body.length}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ API funcionando!');
      print('📝 Total de exercícios: ${data['count']}');
      print('🏋️ Exercícios na resposta: ${data['results'].length}');

      // Mostrar primeiro exercício como exemplo
      if (data['results'].isNotEmpty) {
        final firstExercise = data['results'][0];

        // Obter nome da tradução
        String exerciseName = 'Nome não encontrado';
        if (firstExercise['translations'] != null &&
            firstExercise['translations'].isNotEmpty) {
          exerciseName =
              firstExercise['translations'][0]['name'] ?? 'Nome não encontrado';
        }

        print('🎯 Exemplo - Nome: $exerciseName');
        print('🎯 Exemplo - ID: ${firstExercise['id']}');
        print(
          '🎯 Exemplo - Músculos: ${firstExercise['muscles']?.length ?? 0}',
        );
        print(
          '🎯 Exemplo - Equipamentos: ${firstExercise['equipment']?.length ?? 0}',
        );
      }
    } else {
      print('❌ Erro HTTP: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
    }
  } catch (e) {
    print('💥 Erro de conexão: $e');
    print('🔧 Tipo do erro: ${e.runtimeType}');

    // Verificar se é erro de certificado SSL
    if (e.toString().contains('certificate') || e.toString().contains('SSL')) {
      print('🚨 Possível problema de certificado SSL');
    }

    // Verificar se é erro de rede
    if (e.toString().contains('network') ||
        e.toString().contains('connection')) {
      print('🌐 Possível problema de conectividade');
    }
  }
}

// Função para testar múltiplos endpoints
Future<void> testAllEndpoints() async {
  final endpoints = [
    'https://wger.de/api/v2/exerciseinfo/?language=2&limit=5',
    'https://wger.de/api/v2/muscle/',
    'https://wger.de/api/v2/equipment/',
  ];

  for (String endpoint in endpoints) {
    print('\n🔗 Testando: $endpoint');
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Sucesso - ${data['results']?.length ?? 0} items');
      } else {
        print('❌ Falha - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Erro: $e');
    }
  }
}

void main() async {
  print('🚀 Iniciando testes da API Wger...\n');

  await testWgerApi();

  print('\n' + '=' * 50);
  print('📋 TESTANDO TODOS OS ENDPOINTS');
  print('=' * 50);

  await testAllEndpoints();

  print('\n✨ Testes concluídos!');
}
