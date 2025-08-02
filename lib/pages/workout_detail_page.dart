import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/exercise_models.dart';
import '../widgets/exercise_image.dart';
import '../widgets/exercise_animation.dart';
import '../services/translation_service.dart';

class WorkoutDetailPage extends StatefulWidget {
  final WorkoutPlan workoutPlan;

  const WorkoutDetailPage({super.key, required this.workoutPlan});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  bool _isWorkoutStarted = false;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  final int _totalSets = 3;
  bool _isResting = false;
  int _restTime = 30; // segundos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.workoutPlan.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareWorkout,
          ),
        ],
      ),
      body: _isWorkoutStarted ? _buildWorkoutSession() : _buildWorkoutPreview(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildWorkoutPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações gerais do treino
          _buildWorkoutHeader(),

          const SizedBox(height: 30),

          // Lista de exercícios
          Text(
            "Exercícios (${widget.workoutPlan.exercises.length})",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),

          ...widget.workoutPlan.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return _buildExerciseCard(exercise, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildWorkoutSession() {
    if (widget.workoutPlan.exercises.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum exercício disponível',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final currentExercise = widget.workoutPlan.exercises[_currentExerciseIndex];

    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(),

        // Exercise display
        Expanded(
          child: _isResting
              ? _buildRestScreen()
              : _buildExerciseScreen(currentExercise),
        ),

        // Controls
        _buildWorkoutControls(),
      ],
    );
  }

  Widget _buildWorkoutHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.workoutPlan.level.color.withOpacity(0.8),
            widget.workoutPlan.level.color.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.workoutPlan.type.icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.workoutPlan.type.displayName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.workoutPlan.level.displayName,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.workoutPlan.description,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                icon: Icons.timer,
                text: '${widget.workoutPlan.estimatedDuration} min',
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.fitness_center,
                text: '${widget.workoutPlan.exercises.length} exercícios',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF7D4FFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  TranslationService.translate(exercise.name),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (exercise.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              TranslationService.translateDescription(exercise.description),
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ExerciseImageWidget(
            exercise: exercise,
            height: 120,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildExerciseInfo('3 séries'),
              const SizedBox(width: 16),
              _buildExerciseInfo('12-15 reps'),
              const SizedBox(width: 16),
              _buildExerciseInfo('30s descanso'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF7D4FFF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF7D4FFF),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress =
        _currentExerciseIndex / widget.workoutPlan.exercises.length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercício ${_currentExerciseIndex + 1} de ${widget.workoutPlan.exercises.length}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Série $_currentSet/$_totalSets',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7D4FFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseScreen(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  TranslationService.translate(exercise.name),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ExerciseAnimationWidget(
                  exercise: exercise,
                  height: 200,
                  borderRadius: BorderRadius.circular(16),
                ),
                const SizedBox(height: 20),
                if (exercise.description.isNotEmpty) ...[
                  Text(
                    TranslationService.translateDescription(
                      exercise.description,
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Color(0xFF7D4FFF), size: 64),
          const SizedBox(height: 20),
          Text(
            'Descanso',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$_restTime segundos',
            style: GoogleFonts.poppins(
              color: const Color(0xFF7D4FFF),
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutControls() {
    if (!_isWorkoutStarted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentExerciseIndex > 0) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _previousExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Anterior',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isResting ? null : _completeSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D4FFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isResting ? 'Descansando...' : 'Série Completa',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_currentExerciseIndex < widget.workoutPlan.exercises.length - 1 ||
              _currentSet < _totalSets) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Próximo',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isWorkoutStarted ? _completeWorkout : _startWorkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isWorkoutStarted
                ? Colors.green
                : const Color(0xFF7D4FFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            _isWorkoutStarted ? 'Finalizar Treino' : 'Iniciar Treino',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutStarted = true;
      _currentExerciseIndex = 0;
      _currentSet = 1;
    });
  }

  void _completeSet() {
    if (_currentSet < _totalSets) {
      setState(() {
        _currentSet++;
        _isResting = true;
        _restTime = 30;
      });

      // Simular timer de descanso
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isResting = false;
          });
        }
      });
    } else {
      _nextExercise();
    }
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.workoutPlan.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _isResting = false;
      });
    } else {
      _completeWorkout();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSet = 1;
        _isResting = false;
      });
    }
  }

  void _completeWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Parabéns! 🎉',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Você completou o treino "${widget.workoutPlan.name}"!',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Finalizar',
              style: GoogleFonts.poppins(
                color: const Color(0xFF7D4FFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareWorkout() {
    // Implementar compartilhamento do treino
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Função de compartilhamento em desenvolvimento'),
        backgroundColor: Color(0xFF7D4FFF),
      ),
    );
  }
}
