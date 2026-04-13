import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';

class PrimerWelcomePage extends StatelessWidget {
  final VoidCallback onProceed;
  final VoidCallback onClose;

  const PrimerWelcomePage({
    super.key,
    required this.onProceed,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppTopBar(
        title: context.l10n.dailySession,
        showClose: true,
        onClose: onClose,
        closeTooltip: context.l10n.close,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PrimerBackgroundPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xxl,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double height = constraints.maxHeight;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: height * 0.3),
                      Text(
                        context.l10n.primerWelcomeTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B9B6E),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: height * 0.2),
                      Text(
                        context.l10n.primerWelcomeDescription,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                          height: 1.6,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: onProceed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF6B9B6E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          context.l10n.proceed,
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimerBackgroundPainter extends CustomPainter {
  static const Color _baseGreen = Color(0xFF6B9B6E);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Path fillPath = Path();
    final double topY = height * 0.21;
    final double midY = height * 0.49;
    final double amplitude = height * 0.06;

    fillPath.moveTo(0, topY);
    for (double x = 0; x <= width; x += 10) {
      final double wave =
          math.sin((x / width) * math.pi * 2) * amplitude;
      fillPath.lineTo(x, topY + wave);
    }
    for (double x = width; x >= 0; x -= 10) {
      final double wave =
          math.sin((x / width) * math.pi * 2 + math.pi / 2) * amplitude * 0.7;
      fillPath.lineTo(x, midY + wave);
    }
    fillPath.close();

    final Paint fillPaint = Paint()
      ..color = _baseGreen.withValues(alpha: 0.25);
    canvas.drawPath(fillPath, fillPaint);

    final List<double> lineOffsets = [0.0, 10.0, 20.0];
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _baseGreen.withValues(alpha: 0.55);

    for (final double offset in lineOffsets) {
      final Path topEdge = Path();
      for (double x = 0; x <= width; x += 8) {
        final double wave =
            math.sin((x / width) * math.pi * 2 + offset * 0.08) *
                (amplitude * 0.55);
        if (x == 0) {
          topEdge.moveTo(x, topY + wave + offset);
        } else {
          topEdge.lineTo(x, topY + wave + offset);
        }
      }
      canvas.drawPath(topEdge, linePaint);

      final Path bottomEdge = Path();
      for (double x = 0; x <= width; x += 8) {
        final double wave =
            math.sin((x / width) * math.pi * 2 + offset * 0.08 + math.pi / 3) *
                (amplitude * 0.5);
        if (x == 0) {
          bottomEdge.moveTo(x, midY + wave - offset);
        } else {
          bottomEdge.lineTo(x, midY + wave - offset);
        }
      }
      canvas.drawPath(
        bottomEdge,
        linePaint..color = _baseGreen.withValues(alpha: 0.5),
      );
    }

    final Path lowerEdge = Path();
    for (double x = 0; x <= width; x += 10) {
      final double wave =
          math.sin((x / width) * math.pi * 2 + math.pi / 2) *
              (amplitude * 0.35);
      if (x == 0) {
        lowerEdge.moveTo(x, midY + height * 0.27 + wave);
      } else {
        lowerEdge.lineTo(x, midY + height * 0.27 + wave);
      }
    }
    canvas.drawPath(
      lowerEdge,
      linePaint..color = _baseGreen.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
