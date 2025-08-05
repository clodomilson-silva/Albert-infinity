import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trainsmart_models.dart';

/// Exceção personalizada para erros da API TrainSmart
class TrainSmartApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  TrainSmartApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (details != null) {
      return 'TrainSmartApiException: $message\nDetalhes: $details';
    }
    return 'TrainSmartApiException: $message';
  }
}

/// Serviço para integração com a API TrainSmart
class TrainSmartApiService {
  static const String baseUrl = 'https://trainsmart-api.onrender.com';
  static TrainSmartApiService? _instance;

  static TrainSmartApiService get instance {
    _instance ??= TrainSmartApiService._internal();
    return _instance!;
  }

  TrainSmartApiService._internal();

  // Cache para exercícios
  List<TrainSmartExercise>? _cachedExercises;
  DateTime? _lastCacheUpdate;
  final Duration _cacheTimeout = const Duration(minutes: 30);

  // Token de autenticação
  String? _accessToken;
  bool get isAuthenticated => _accessToken != null;

  bool get _shouldUpdateCache {
    if (_lastCacheUpdate == null) return true;
    return DateTime.now().difference(_lastCacheUpdate!) > _cacheTimeout;
  }

  /// Headers padrão para requisições
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Tratamento de erros HTTP
  void _handleHttpError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Sucesso
    }

    String errorMessage;
    String? details;

    try {
      final errorBody = jsonDecode(response.body);
      errorMessage = errorBody['detail'] ?? errorBody['message'] ?? 'Erro desconhecido';
      details = errorBody.toString();
    } catch (e) {
      errorMessage = 'Erro HTTP ${response.statusCode}';
      details = response.body;
    }

    throw TrainSmartApiException(errorMessage, statusCode: response.statusCode, details: details);
  }

  // ========== AUTENTICAÇÃO ==========

  /// Fazer login na API
  Future<AuthResponse> login(LoginCredentials credentials) async {
    try {
      print('🔐 Fazendo login na TrainSmart API...');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credentials.toJson()),
      );

      _handleHttpError(response);

      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      _accessToken = authResponse.accessToken;

      print('✅ Login realizado com sucesso!');
      return authResponse;
    } catch (e) {
      print('❌ Erro no login: $e');
      rethrow;
    }
  }

  /// Registrar novo usuário
  Future<TrainSmartUser> register(RegisterData registerData) async {
    try {
      print('📝 Registrando novo usuário...');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerData.toJson()),
      );

      _handleHttpError(response);

      final userData = TrainSmartUser.fromJson(jsonDecode(response.body));
      print('✅ Usuário registrado com sucesso!');
      return userData;
    } catch (e) {
      print('❌ Erro no registro: $e');
      rethrow;
    }
  }

  /// Fazer logout
  void logout() {
    _accessToken = null;
    print('🚪 Logout realizado');
  }

  // ========== STATUS E INFORMAÇÕES ==========

  /// Obter informações da API
  Future<ApiStatus> getApiInfo() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: _headers);

      _handleHttpError(response);
      return ApiStatus.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('❌ Erro ao obter informações da API: $e');
      rethrow;
    }
  }

  /// Health check da API
  Future<HealthStatus> getHealthStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'), headers: _headers);

      _handleHttpError(response);
      return HealthStatus.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('❌ Erro no health check: $e');
      rethrow;
    }
  }

  // ========== EXERCÍCIOS ==========

  /// Listar exercícios (público)
  Future<List<TrainSmartExercise>> getExercises({
    String? grupoMuscular,
    String? equipamento,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      print('🏋️ Carregando exercícios da TrainSmart API...');

      // Usar cache se disponível e não expirado
      if (_cachedExercises != null &&
          !_shouldUpdateCache &&
          grupoMuscular == null &&
          equipamento == null) {
        print('📋 Usando cache de exercícios (${_cachedExercises!.length} exercícios)');
        return _cachedExercises!;
      }

      // Construir URL com parâmetros
      final uri = Uri.parse('$baseUrl/exercicios').replace(
        queryParameters: {
          if (grupoMuscular != null) 'grupo_muscular': grupoMuscular,
          if (equipamento != null) 'equipamento': equipamento,
          'skip': skip.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);
      _handleHttpError(response);

      final List<dynamic> exercisesJson = jsonDecode(response.body);
      final exercises = exercisesJson.map((json) => TrainSmartExercise.fromJson(json)).toList();

      // Atualizar cache se for uma busca completa
      if (grupoMuscular == null && equipamento == null) {
        _cachedExercises = exercises;
        _lastCacheUpdate = DateTime.now();
      }

      print('✅ ${exercises.length} exercícios carregados com sucesso!');
      return exercises;
    } catch (e) {
      print('❌ Erro ao carregar exercícios: $e');
      rethrow;
    }
  }

  /// Buscar exercício por ID
  Future<TrainSmartExercise> getExerciseById(int id) async {
    try {
      print('🔍 Buscando exercício ID: $id');

      final response = await http.get(Uri.parse('$baseUrl/exercicios/$id'), headers: _headers);

      _handleHttpError(response);

      final exercise = TrainSmartExercise.fromJson(jsonDecode(response.body));
      print('✅ Exercício encontrado: ${exercise.nome}');
      return exercise;
    } catch (e) {
      print('❌ Erro ao buscar exercício: $e');
      rethrow;
    }
  }

  /// Criar novo exercício (requer autenticação de admin)
  Future<TrainSmartExercise> createExercise(ExerciseCreateData exerciseData) async {
    if (!isAuthenticated) {
      throw TrainSmartApiException('Autenticação necessária para criar exercícios');
    }

    try {
      print('➕ Criando novo exercício: ${exerciseData.nome}');

      final response = await http.post(
        Uri.parse('$baseUrl/exercicios'),
        headers: _headers,
        body: jsonEncode(exerciseData.toJson()),
      );

      _handleHttpError(response);

      final exercise = TrainSmartExercise.fromJson(jsonDecode(response.body));

      // Invalidar cache
      _cachedExercises = null;

      print('✅ Exercício criado com sucesso!');
      return exercise;
    } catch (e) {
      print('❌ Erro ao criar exercício: $e');
      rethrow;
    }
  }

  /// Atualizar exercício (requer autenticação de admin)
  Future<TrainSmartExercise> updateExercise(int id, ExerciseCreateData exerciseData) async {
    if (!isAuthenticated) {
      throw TrainSmartApiException('Autenticação necessária para atualizar exercícios');
    }

    try {
      print('✏️ Atualizando exercício ID: $id');

      final response = await http.put(
        Uri.parse('$baseUrl/exercicios/$id'),
        headers: _headers,
        body: jsonEncode(exerciseData.toJson()),
      );

      _handleHttpError(response);

      final exercise = TrainSmartExercise.fromJson(jsonDecode(response.body));

      // Invalidar cache
      _cachedExercises = null;

      print('✅ Exercício atualizado com sucesso!');
      return exercise;
    } catch (e) {
      print('❌ Erro ao atualizar exercício: $e');
      rethrow;
    }
  }

  /// Excluir exercício (requer autenticação de admin)
  Future<void> deleteExercise(int id) async {
    if (!isAuthenticated) {
      throw TrainSmartApiException('Autenticação necessária para excluir exercícios');
    }

    try {
      print('🗑️ Excluindo exercício ID: $id');

      final response = await http.delete(Uri.parse('$baseUrl/exercicios/$id'), headers: _headers);

      _handleHttpError(response);

      // Invalidar cache
      _cachedExercises = null;

      print('✅ Exercício excluído com sucesso!');
    } catch (e) {
      print('❌ Erro ao excluir exercício: $e');
      rethrow;
    }
  }

  // ========== UTILITÁRIOS ==========

  /// Listar grupos musculares disponíveis
  Future<List<String>> getGruposMusculares() async {
    try {
      print('💪 Carregando grupos musculares...');

      final response = await http.get(
        Uri.parse('$baseUrl/exercicios/grupos-musculares'),
        headers: _headers,
      );

      _handleHttpError(response);

      final List<dynamic> grupos = jsonDecode(response.body);
      final gruposMusculares = grupos.cast<String>();

      print('✅ ${gruposMusculares.length} grupos musculares carregados');
      return gruposMusculares;
    } catch (e) {
      print('❌ Erro ao carregar grupos musculares: $e');
      rethrow;
    }
  }

  /// Listar equipamentos disponíveis
  Future<List<String>> getEquipamentos() async {
    try {
      print('🏋️ Carregando equipamentos...');

      final response = await http.get(
        Uri.parse('$baseUrl/exercicios/equipamentos'),
        headers: _headers,
      );

      _handleHttpError(response);

      final List<dynamic> equipamentos = jsonDecode(response.body);
      final listaEquipamentos = equipamentos.cast<String>();

      print('✅ ${listaEquipamentos.length} equipamentos carregados');
      return listaEquipamentos;
    } catch (e) {
      print('❌ Erro ao carregar equipamentos: $e');
      rethrow;
    }
  }

  // ========== UTILITÁRIOS DE CACHE ==========

  /// Limpar cache de exercícios
  void clearCache() {
    _cachedExercises = null;
    _lastCacheUpdate = null;
    print('🧹 Cache limpo');
  }

  /// Forçar atualização do cache
  Future<List<TrainSmartExercise>> refreshCache() async {
    clearCache();
    return await getExercises();
  }

  // ========== STATUS E ESTATÍSTICAS ==========

  /// Obter estatísticas do cache
  Map<String, dynamic> getCacheStats() {
    return {
      'has_cache': _cachedExercises != null,
      'cache_size': _cachedExercises?.length ?? 0,
      'last_update': _lastCacheUpdate?.toIso8601String(),
      'cache_age_minutes': _lastCacheUpdate != null
          ? DateTime.now().difference(_lastCacheUpdate!).inMinutes
          : null,
      'should_update': _shouldUpdateCache,
    };
  }
}
