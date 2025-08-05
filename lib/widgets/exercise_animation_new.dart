import 'package:flutter/material.dart';
import '../models/trainsmart_models.dart';

class ExerciseAnimationWidget extends StatefulWidget {
  final TrainSmartExercise exercise;
  final double height;
  final BorderRadius? borderRadius;

  const ExerciseAnimationWidget({
    super.key,
    required this.exercise,
    this.height = 200,
    this.borderRadius,
  });

  @override
  State<ExerciseAnimationWidget> createState() => _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Se há GIF, iniciar animação
    if (widget.exercise.gifUrl != null && widget.exercise.gifUrl!.isNotEmpty) {
      _startGifAnimation();
    }
  }

  void _startGifAnimation() {
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
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

    if (widget.exercise.gifUrl == null || widget.exercise.gifUrl!.isEmpty) {
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
        child: Stack(children: [_buildExerciseGif(), _buildOverlayInfo(), _buildPlayButton()]),
      ),
    );
  }

  Widget _buildExerciseGif() {
    if (widget.exercise.gifUrl == null || widget.exercise.gifUrl!.isEmpty) {
      return _buildAnimatedFallback(BorderRadius.circular(12));
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * 0.05), // Leve zoom
          child: Image.network(
            widget.exercise.gifUrl!,
            height: widget.height,
            width: double.infinity,
            fit: BoxFit.cover,
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
              widget.exercise.nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.exercise.gifUrl != null && widget.exercise.gifUrl!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.animation, color: const Color(0xFF7D4FFF), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Demonstração animada',
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
    if (widget.exercise.gifUrl == null || widget.exercise.gifUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

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
                    widget.exercise.iconeGrupoMuscular,
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
                  widget.exercise.nome,
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
}
