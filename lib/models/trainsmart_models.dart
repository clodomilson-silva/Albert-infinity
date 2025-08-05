import 'package:flutter/material.dart';

/// Modelo para representar um exercício da API TrainSmart
class TrainSmartExercise {
  final int id;
  final String nome;
  final String descricao;
  final String grupoMuscular;
  final String equipamento;
  final String? nivel; // Tornando opcional pois a API pode retornar null
  final String? gifUrl;

  TrainSmartExercise({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.grupoMuscular,
    required this.equipamento,
    this.nivel,
    this.gifUrl,
  });

  factory TrainSmartExercise.fromJson(Map<String, dynamic> json) {
    return TrainSmartExercise(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      grupoMuscular: json['grupo_muscular'] ?? '',
      equipamento: json['equipamento'] ?? '',
      nivel: json['nivel'],
      gifUrl: json['gif_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'grupo_muscular': grupoMuscular,
      'equipamento': equipamento,
      'nivel': nivel,
      'gif_url': gifUrl,
    };
  }

  /// Converte o nível para um enum mais fácil de usar
  NivelExercicio get nivelEnum {
    if (nivel == null) return NivelExercicio.iniciante;

    switch (nivel!.toLowerCase()) {
      case 'iniciante':
        return NivelExercicio.iniciante;
      case 'intermediario':
      case 'intermediário':
        return NivelExercicio.intermediario;
      case 'avancado':
      case 'avançado':
        return NivelExercicio.avancado;
      default:
        return NivelExercicio.iniciante;
    }
  }

  /// Retorna a cor baseada no nível
  Color get corNivel {
    switch (nivelEnum) {
      case NivelExercicio.iniciante:
        return Colors.green;
      case NivelExercicio.intermediario:
        return Colors.orange;
      case NivelExercicio.avancado:
        return Colors.red;
    }
  }

  /// Retorna um ícone baseado no grupo muscular
  IconData get iconeGrupoMuscular {
    switch (grupoMuscular.toLowerCase()) {
      case 'peito':
        return Icons.fitness_center;
      case 'costas':
        return Icons.view_column;
      case 'pernas':
        return Icons.directions_run;
      case 'braços':
      case 'bracos':
        return Icons.sports_handball;
      case 'ombros':
        return Icons.expand_more;
      case 'abdômen':
      case 'abdomen':
        return Icons.crop_square;
      default:
        return Icons.fitness_center;
    }
  }
}

/// Enum para níveis de exercício
enum NivelExercicio {
  iniciante,
  intermediario,
  avancado;

  String get displayName {
    switch (this) {
      case NivelExercicio.iniciante:
        return 'Iniciante';
      case NivelExercicio.intermediario:
        return 'Intermediário';
      case NivelExercicio.avancado:
        return 'Avançado';
    }
  }
}

/// Modelo para usuário da API
class TrainSmartUser {
  final int id;
  final String username;
  final String email;
  final bool isAdmin;

  TrainSmartUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isAdmin,
  });

  factory TrainSmartUser.fromJson(Map<String, dynamic> json) {
    return TrainSmartUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['is_admin'] ?? false,
    );
  }
}

/// Modelo para resposta de autenticação
class AuthResponse {
  final String accessToken;
  final String tokenType;

  AuthResponse({required this.accessToken, required this.tokenType});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
}

/// Modelo para credenciais de login
class LoginCredentials {
  final String username;
  final String password;

  LoginCredentials({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

/// Modelo para registro de usuário
class RegisterData {
  final String username;
  final String email;
  final String password;

  RegisterData({required this.username, required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'password': password};
  }
}

/// Modelo para criação/atualização de exercício
class ExerciseCreateData {
  final String nome;
  final String descricao;
  final String grupoMuscular;
  final String equipamento;
  final String nivel;
  final String? gifUrl;

  ExerciseCreateData({
    required this.nome,
    required this.descricao,
    required this.grupoMuscular,
    required this.equipamento,
    required this.nivel,
    this.gifUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'grupo_muscular': grupoMuscular,
      'equipamento': equipamento,
      'nivel': nivel,
      if (gifUrl != null) 'gif_url': gifUrl,
    };
  }
}

/// Modelo para status da API
class ApiStatus {
  final String message;
  final String version;
  final DateTime timestamp;

  ApiStatus({required this.message, required this.version, required this.timestamp});

  factory ApiStatus.fromJson(Map<String, dynamic> json) {
    return ApiStatus(
      message: json['message'] ?? '',
      version: json['version'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Modelo para health check
class HealthStatus {
  final String status;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  HealthStatus({required this.status, required this.timestamp, this.details});

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      details: json['details'],
    );
  }

  bool get isHealthy => status.toLowerCase() == 'ok' || status.toLowerCase() == 'healthy';
}
