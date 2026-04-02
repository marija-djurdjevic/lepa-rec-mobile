import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';

class JournalFeedbackPage extends StatelessWidget {
  final String feedbackType;

  const JournalFeedbackPage({super.key, required this.feedbackType});

  String _getFeedbackMessage(BuildContext context) {
    switch (feedbackType) {
      case 'GoodDistancing':
        return context.l10n.goodDistancingFeedback;
      case 'MixedDistancing':
        return context.l10n.mixedDistancingFeedback;
      case 'NeedsMoreDistancing':
        return context.l10n.needsMoreDistancingFeedback;
      default:
        return context.l10n.mixedDistancingFeedback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B9B6E),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          context.l10n.journalFeedbackTitle,
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FeedbackBackgroundPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(),
                  Column(
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 44,
                        color: const Color(0xFF6B9B6E)
                            .withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        context.l10n.journalFeedbackSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F3A2F),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _getFeedbackMessage(context),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF2F3A2F),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B9B6E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.continueToDashboard,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackBackgroundPainter extends CustomPainter {
  static const Color _baseGreen = Color(0xFF6B9B6E);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final double topY = height * 0.16;
    final double midY = height * 0.68;
    final double amplitude = height * 0.06;

    final Path fillPath = Path()..moveTo(0, topY);
    for (double x = 0; x <= width; x += 10) {
      final double wave = math.sin((x / width) * math.pi * 2) * amplitude;
      fillPath.lineTo(x, topY + wave);
    }
    for (double x = width; x >= 0; x -= 10) {
      final double wave =
          math.sin((x / width) * math.pi * 2 + math.pi / 2) *
              amplitude *
              0.7;
      fillPath.lineTo(x, midY + wave);
    }
    fillPath.close();

    final Paint fillPaint =
        Paint()..color = _baseGreen.withValues(alpha: 0.2);
    canvas.drawPath(fillPath, fillPaint);

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _baseGreen.withValues(alpha: 0.55);

    final List<double> offsets = [0, 10, 20, 30];
    for (final offset in offsets) {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
