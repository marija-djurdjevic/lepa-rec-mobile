import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/breathing_exercise_page.dart';

class BreathingCircle extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> phaseBlend;
  final BreathingPhase phase;
  final BreathingPhase previousPhase;
  final bool isIdle;
  final VoidCallback? onTap;
  final String idleText;

  const BreathingCircle({
    super.key,
    required this.animation,
    required this.phaseBlend,
    required this.phase,
    required this.previousPhase,
    required this.isIdle,
    required this.onTap,
    required this.idleText,
  });

  @override
  Widget build(BuildContext context) {
    const double activeSize = 200;
    const double idleSize = 200;

    if (isIdle) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: idleSize,
          height: idleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      idleText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B9B6E),
                        height: 1.3,
                      ),
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
      animation: Listenable.merge([animation, phaseBlend]),
      builder: (context, child) {
        final Animation<double> eased =
            CurvedAnimation(parent: animation, curve: Curves.easeInOutSine);
        final double t = eased.value;
        const double minScale = 1.18;
        const double maxScale = 1.32;
        double scale = minScale;

        switch (phase) {
          case BreathingPhase.breathIn:
            scale = minScale + (t * (maxScale - minScale));
            break;
          case BreathingPhase.hold:
            scale = maxScale;
            break;
          case BreathingPhase.breathOut:
            scale = maxScale - (t * (maxScale - minScale));
            break;
          case BreathingPhase.pause:
            scale = minScale;
            break;
        }

        final double previousScale =
            _scaleForPhase(previousPhase, 1.0, minScale, maxScale);
        final double blendedScale = lerpDouble(
              previousScale,
              scale,
              phaseBlend.value,
            ) ??
            scale;
        final double bloom = ((blendedScale - minScale) /
                (maxScale - minScale))
            .clamp(0.0, 1.0);
        final double rotation = lerpDouble(
              _rotationForT(1.0),
              _rotationForT(t),
              phaseBlend.value,
            ) ??
            _rotationForT(t);
        const Color baseColor = Color(0xFF6B9B6E);

        return Transform.scale(
          scale: blendedScale,
          child: SizedBox(
            width: activeSize,
            height: activeSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        baseColor.withValues(alpha: 0.18),
                        baseColor.withValues(alpha: 0.02),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: rotation,
                  child: CustomPaint(
                    size: const Size.square(200),
                    painter: _BreathingFlowerPainter(
                      bloom: bloom,
                      color: baseColor,
                    ),
                  ),
                ),
                Container(
                  width: 92 + (18 * bloom),
                  height: 92 + (18 * bloom),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        baseColor.withValues(alpha: 0.55),
                        baseColor.withValues(alpha: 0.18),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                    border: Border.all(
                      color: baseColor.withValues(alpha: 0.65),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _scaleForPhase(
    BreathingPhase phase,
    double t,
    double minScale,
    double maxScale,
  ) {
    return switch (phase) {
      BreathingPhase.breathIn => minScale + (t * (maxScale - minScale)),
      BreathingPhase.hold => maxScale,
      BreathingPhase.breathOut => maxScale - (t * (maxScale - minScale)),
      BreathingPhase.pause => minScale,
    };
  }

  double _rotationForT(double t) => 0.0;
}

class _BreathingFlowerPainter extends CustomPainter {
  final double bloom;
  final Color color;

  const _BreathingFlowerPainter({
    required this.bloom,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double petalDistance = size.width * (0.24 + (0.03 * bloom));
    final double petalRadius = size.width * (0.18 + (0.05 * bloom));

    final Paint petalPaint = Paint()
      ..color = color.withValues(alpha: 0.22 + (0.12 * bloom))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final Paint petalStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = color.withValues(alpha: 0.55 + (0.2 * bloom))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    const int petalCount = 10;
    for (int i = 0; i < petalCount; i++) {
      final double angle = (math.pi * 2 / petalCount) * i;
      final Offset offset =
          Offset(math.cos(angle), math.sin(angle)) * petalDistance;
      final Offset petalCenter = center + offset;
      canvas.drawCircle(petalCenter, petalRadius, petalPaint);
      final Rect petalRect = Rect.fromCenter(
        center: petalCenter,
        width: petalRadius * 1.5,
        height: petalRadius * 2.1,
      );
      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle);
      canvas.translate(-petalCenter.dx, -petalCenter.dy);
      canvas.drawOval(petalRect, petalStroke);
      canvas.restore();
    }

    final Paint petalPaintInner = Paint()
      ..color = color.withValues(alpha: 0.18 + (0.1 * bloom))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (int i = 0; i < petalCount; i++) {
      final double angle = (math.pi * 2 / petalCount) * i + (math.pi / petalCount);
      final Offset offset =
          Offset(math.cos(angle), math.sin(angle)) * (petalDistance * 0.75);
      final Offset petalCenter = center + offset;
      canvas.drawCircle(petalCenter, petalRadius * 0.75, petalPaintInner);
      final Rect petalRect = Rect.fromCenter(
        center: petalCenter,
        width: petalRadius * 1.1,
        height: petalRadius * 1.6,
      );
      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle);
      canvas.translate(-petalCenter.dx, -petalCenter.dy);
      canvas.drawOval(petalRect, petalStroke);
      canvas.restore();
    }

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: 0.45 + (0.2 * bloom));

    canvas.drawCircle(center, size.width * 0.28, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _BreathingFlowerPainter oldDelegate) {
    return oldDelegate.bloom != bloom || oldDelegate.color != color;
  }
}
