import 'package:flutter/material.dart';
import '../models/exercise_models.dart';

class ExerciseAnimationWidget extends StatefulWidget {
  final Exercise exercise;
  final double height;
  final BorderRadius? borderRadius;

  const ExerciseAnimationWidget({
    super.key,
    required this.exercise,
    this.height = 200,
    this.borderRadius,
  });

  @override
  State<ExerciseAnimationWidget> createState() =>
      _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Se há múltiplas imagens, criar animação alternando entre elas
    if (widget.exercise.images.length > 1) {
      _startImageAnimation();
    }
  }

  void _startImageAnimation() {
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % widget.exercise.images.length;
        });
        _animationController.reset();
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRad = widget.borderRadius ?? BorderRadius.circular(12);

    if (widget.exercise.images.isEmpty) {
      return _buildAnimatedFallback(borderRad);
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: borderRad,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRad,
        child: Stack(
          children: [
            _buildExerciseImage(),
            _buildOverlayInfo(),
            _buildPlayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseImage() {
    if (widget.exercise.images.isEmpty) {
      return _buildAnimatedFallback(BorderRadius.circular(12));
    }

    String imageUrl = widget.exercise.images[_currentImageIndex].image;

    // Corrigir URL caso seja relativa
    if (!imageUrl.startsWith('http')) {
      imageUrl = 'https://wger.de$imageUrl';
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * 0.05), // Leve zoom
          child: Image.network(
            imageUrl,
            height: widget.height,
            width: double.infinity,
            fit: BoxFit.cover,
            headers: const {'User-Agent': 'AlbertInfinity/1.0'},
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey.shade800, Colors.grey.shade900],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF7D4FFF),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Carregando animação...',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildAnimatedFallback(BorderRadius.circular(12));
            },
          ),
        );
      },
    );
  }

  Widget _buildOverlayInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.exercise.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.exercise.images.length > 1) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.animation,
                    color: const Color(0xFF7D4FFF),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.exercise.images.length} poses',
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 10),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    if (widget.exercise.images.length <= 1) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: () {
          if (_animationController.isAnimating) {
            _animationController.stop();
          } else {
            _animationController.forward();
          }
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _animationController.isAnimating ? Icons.pause : Icons.play_arrow,
            color: const Color(0xFF7D4FFF),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFallback(BorderRadius borderRad) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: borderRad,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800.withOpacity(0.8 + _animation.value * 0.2),
                Colors.grey.shade900.withOpacity(0.8 + _animation.value * 0.2),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: _animation.value * 2 * 3.14159,
                  child: Icon(
                    _getExerciseIcon(),
                    color: Color.lerp(
                      const Color(0xFF7D4FFF).withOpacity(0.6),
                      const Color(0xFF7D4FFF),
                      _animation.value,
                    ),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.exercise.name,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Animação indisponível',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getExerciseIcon() {
    final name = widget.exercise.name.toLowerCase();

    if (name.contains('flexão') ||
        name.contains('push') ||
        name.contains('press')) {
      return Icons.fitness_center;
    } else if (name.contains('agachamento') ||
        name.contains('squat') ||
        name.contains('leg')) {
      return Icons.accessibility_new;
    } else if (name.contains('corrida') ||
        name.contains('run') ||
        name.contains('cardio')) {
      return Icons.directions_run;
    } else if (name.contains('abdominal') ||
        name.contains('core') ||
        name.contains('plank')) {
      return Icons.center_focus_strong;
    } else if (name.contains('bíceps') ||
        name.contains('tríceps') ||
        name.contains('arm')) {
      return Icons.sports_martial_arts;
    } else {
      return Icons.fitness_center;
    }
  }
}
