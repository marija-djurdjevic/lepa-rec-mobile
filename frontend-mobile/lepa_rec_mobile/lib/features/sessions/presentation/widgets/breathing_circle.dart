import 'package:flutter/material.dart';

import '../pages/breathing_exercise_page.dart';

class BreathingCircle extends StatelessWidget {
  final Animation<double> animation;
  final BreathingPhase phase;

  const BreathingCircle({
    super.key,
    required this.animation,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        double scale = 1.0;

        switch (phase) {
          case BreathingPhase.breathIn:
            // Scale up from 1.0 to 1.5
            scale = 1.0 + (animation.value * 0.5);
            break;
          case BreathingPhase.hold:
            // Stay at max size
            scale = 1.5;
            break;
          case BreathingPhase.breathOut:
            // Scale down from 1.5 to 1.0
            scale = 1.5 - (animation.value * 0.5);
            break;
        }

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6B9B6E).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF6B9B6E),
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}
