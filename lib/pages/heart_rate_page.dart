import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/health_service.dart';

class HeartRatePage extends StatefulWidget {
  const HeartRatePage({super.key});

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  final HealthService _healthService = HealthService.instance;
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isMonitoring = false;
  int _heartRate = 0;
  int _countdown = 0;
  Timer? _measurementTimer;
  Timer? _countdownTimer;
  StreamSubscription<int>? _heartRateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _measurementTimer?.cancel();
    _countdownTimer?.cancel();
    _heartRateSubscription?.cancel();

    // Parar o sensor cardíaco quando sair da página
    _healthService.stopHeartRateMonitoring();

    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('Nenhuma câmera encontrada');
        return;
      }

      // Usar câmera traseira se disponível
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      _showError('Erro ao inicializar câmera: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _startMeasurement() {
    if (!_isInitialized || _cameraController == null) {
      _showError('Câmera não está pronta');
      return;
    }

    setState(() {
      _isMonitoring = true;
      _countdown = 15; // 15 segundos de medição
      _heartRate = 0;
    });

    // Ligar o flash da câmera
    _cameraController!.setFlashMode(FlashMode.torch);

    // Iniciar o sensor de batimentos cardíacos
    _healthService.startHeartRateMonitoring();

    // Escutar os dados do sensor
    _heartRateSubscription = _healthService.heartRateStream.listen((heartRate) {
      if (_isMonitoring && mounted) {
        setState(() {
          _heartRate = heartRate;
        });
      }
    });

    // Timer para contagem regressiva
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        _stopMeasurement();
      }
    });

    // Remover o timer de simulação, agora usando dados reais do sensor
    // _measurementTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    //   if (_isMonitoring) {
    //     _simulateHeartRateReading();
    //   }
    // });
  }

  void _stopMeasurement() {
    _measurementTimer?.cancel();
    _countdownTimer?.cancel();
    _heartRateSubscription?.cancel();
    _cameraController?.setFlashMode(FlashMode.off);

    // Parar o sensor de batimentos cardíacos
    _healthService.stopHeartRateMonitoring();

    setState(() {
      _isMonitoring = false;
      _countdown = 0;
    });

    if (_heartRate > 0) {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Resultado da Medição',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              '$_heartRate BPM',
              style: GoogleFonts.poppins(
                color: Color(0xFF7D4FFF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _getHeartRateStatus(_heartRate),
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: Color(0xFF7D4FFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHeartRateStatus(int bpm) {
    if (bpm < 60) return 'Abaixo do normal (Bradicardia)';
    if (bpm <= 100) return 'Normal (Frequência cardíaca saudável)';
    return 'Acima do normal (Taquicardia)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Medição de Batimentos',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF7D4FFF)),
            SizedBox(height: 16),
            Text(
              'Inicializando câmera...',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Instruções
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.fingerprint, color: Color(0xFF7D4FFF), size: 64),
              SizedBox(height: 16),
              Text(
                'Como medir:',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '1. Coloque o dedo indicador sobre a câmera traseira\n'
                '2. Cubra completamente a lente\n'
                '3. Mantenha o dedo parado durante a medição\n'
                '4. A medição durará 15 segundos',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Preview da câmera
        Expanded(
          child: Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isMonitoring ? Colors.red : Color(0xFF7D4FFF),
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: _cameraController != null
                  ? CameraPreview(_cameraController!)
                  : Container(
                      color: Colors.grey.shade900,
                      child: Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white54,
                          size: 64,
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // Status da medição
        if (_isMonitoring) ...[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Medindo...',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$_countdown segundos restantes',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
                if (_heartRate > 0) ...[
                  SizedBox(height: 12),
                  Text(
                    '$_heartRate BPM',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF7D4FFF),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),
        ],

        // Botão de medição
        Padding(
          padding: EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isMonitoring ? _stopMeasurement : _startMeasurement,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMonitoring ? Colors.red : Color(0xFF7D4FFF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _isMonitoring ? 'Parar Medição' : 'Iniciar Medição',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
