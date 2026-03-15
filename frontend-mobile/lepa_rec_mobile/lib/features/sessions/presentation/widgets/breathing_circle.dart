import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/breathing_exercise_page.dart';

class BreathingCircle extends StatelessWidget {
  final Animation<double> animation;
  final BreathingPhase phase;
  final bool isIdle;
  final VoidCallback? onTap;
  final String idleText;

  const BreathingCircle({
    super.key,
    required this.animation,
    required this.phase,
    required this.isIdle,
    required this.onTap,
    required this.idleText,
  });

  @override
  Widget build(BuildContext context) {
    if (isIdle) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF6B9B6E).withOpacity(0.12),
            border: Border.all(
              color: const Color(0xFF6B9B6E),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B9B6E).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  size: 44,
                  color: Color(0xFF6B9B6E),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    idleText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B9B6E),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        double scale = 1.0;

        switch (phase) {
          case BreathingPhase.breathIn:
            scale = 1.0 + (animation.value * 0.5);
            break;
          case BreathingPhase.hold:
            scale = 1.5;
            break;
          case BreathingPhase.breathOut:
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
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B9B6E).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}