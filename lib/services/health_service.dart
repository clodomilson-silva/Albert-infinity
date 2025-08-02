import 'dart:async';
import 'dart:math';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthService {
  static HealthService? _instance;
  static HealthService get instance {
    _instance ??= HealthService._internal();
    return _instance!;
  }
  
  HealthService._internal();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream controllers para os dados de saúde
  final StreamController<int> _stepsController = StreamController<int>.broadcast();
  final StreamController<double> _caloriesController = StreamController<double>.broadcast();
  final StreamController<int> _heartRateController = StreamController<int>.broadcast();
  
  // Getters para os streams
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<double> get caloriesStream => _caloriesController.stream;
  Stream<int> get heartRateStream => _heartRateController.stream;
  
  // Getter para verificar se está monitorando batimentos
  bool get isHeartRateMonitoring => _isHeartRateMonitoring;
  
  // Variáveis de controle
  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;
  Timer? _heartRateTimer;
  
  int _currentSteps = 0;
  int _initialSteps = 0;
  bool _isInitialized = false;
  bool _isHeartRateMonitoring = false;
  
  // Inicializar o serviço de saúde
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _requestPermissions();
    await _initializePedometer();
    await _loadTodayData();
    
    _isInitialized = true;
  }
  
  // Solicitar permissões necessárias
  Future<void> _requestPermissions() async {
    // Permissão para atividade física
    await Permission.activityRecognition.request();
    await Permission.sensors.request();
  }
  
  // Inicializar o pedômetro
  Future<void> _initializePedometer() async {
    try {
      // Stream para contagem de passos
      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
      
      // Stream para status do pedestre
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
      );
      
    } catch (e) {
      print('Erro ao inicializar pedômetro: $e');
    }
  }
  
  // Callback para contagem de passos
  void _onStepCount(StepCount event) {
    if (!_isInitialized) {
      _initialSteps = event.steps;
      _isInitialized = true;
    }
    
    _currentSteps = event.steps - _initialSteps;
    _stepsController.add(_currentSteps);
    
    // Calcular calorias baseado nos passos
    double calories = _calculateCalories(_currentSteps);
    _caloriesController.add(calories);
    
    // Salvar dados no Firestore
    _saveTodayData();
  }
  
  // Callback para erro de contagem de passos
  void _onStepCountError(error) {
    print('Erro no pedômetro: $error');
  }
  
  // Callback para mudança de status do pedestre
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    print('Status do pedestre: ${event.status}');
  }
  
  // Callback para erro de status do pedestre
  void _onPedestrianStatusError(error) {
    print('Erro no status do pedestre: $error');
  }
  
  // Calcular calorias baseado nos passos
  double _calculateCalories(int steps) {
    // Fórmula baseada em pesquisas:
    // - Pessoa média: 0.04-0.05 calorias por passo
    // - Considerando peso médio de 70kg
    // - Altura média de 1.70m
    const double caloriesPerStep = 0.045;
    return steps * caloriesPerStep;
  }
  
  // Simular medição de batimentos cardíacos
  void startHeartRateMonitoring() {
    if (_isHeartRateMonitoring) return; // Já está monitorando
    
    _heartRateTimer?.cancel();
    _isHeartRateMonitoring = true;
    
    // Simular variação de batimentos (60-100 bpm normal)
    _heartRateTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      // Simular batimentos baseado na atividade
      int baseHeartRate = 70;
      int variation = Random().nextInt(20) - 10; // -10 a +10
      int heartRate = baseHeartRate + variation;
      
      // Ajustar baseado na atividade (se está caminhando)
      if (_currentSteps > 0) {
        heartRate += 20; // Aumentar se estiver ativo
      }
      
      // Manter dentro de limites realistas
      heartRate = heartRate.clamp(60, 120);
      
      _heartRateController.add(heartRate);
    });
  }
  
  // Parar monitoramento de batimentos
  void stopHeartRateMonitoring() {
    _heartRateTimer?.cancel();
    _isHeartRateMonitoring = false;
  }
  
  // Carregar dados do dia atual
  Future<void> _loadTodayData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final today = DateTime.now();
    final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_data')
          .doc(dateString)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _currentSteps = data['steps'] ?? 0;
        _stepsController.add(_currentSteps);
        
        double calories = data['calories'] ?? 0.0;
        _caloriesController.add(calories);
      }
    } catch (e) {
      print('Erro ao carregar dados do dia: $e');
    }
  }
  
  // Salvar dados do dia atual
  Future<void> _saveTodayData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final today = DateTime.now();
    final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_data')
          .doc(dateString)
          .set({
        'steps': _currentSteps,
        'calories': _calculateCalories(_currentSteps),
        'date': today,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao salvar dados do dia: $e');
    }
  }
  
  // Obter histórico de dados
  Future<List<Map<String, dynamic>>> getWeeklyData() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_data')
          .where('date', isGreaterThanOrEqualTo: weekAgo)
          .orderBy('date')
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'date': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Erro ao obter dados semanais: $e');
      return [];
    }
  }
  
  // Resetar contador de passos (início do dia)
  void resetDailySteps() {
    _currentSteps = 0;
    _initialSteps = 0;
    _stepsController.add(0);
    _caloriesController.add(0.0);
  }
  
  // Obter dados atuais
  Map<String, dynamic> getCurrentData() {
    return {
      'steps': _currentSteps,
      'calories': _calculateCalories(_currentSteps),
    };
  }
  
  // Dispose dos recursos
  void dispose() {
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    _heartRateTimer?.cancel();
    _stepsController.close();
    _caloriesController.close();
    _heartRateController.close();
  }
}
