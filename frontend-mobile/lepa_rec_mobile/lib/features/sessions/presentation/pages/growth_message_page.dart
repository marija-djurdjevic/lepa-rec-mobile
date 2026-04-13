import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/features/sessions/presentation/state/primer_flow_state.dart';

import '../../../../core/constants/app_spacing.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../data/dtos/complete_primer_dto.dart';
import '../../data/dtos/growth_message_dto.dart';
import '../../data/dtos/growth_message_type.dart';
import '../../data/repositories/session_repository.dart';

class GrowthMessagePage extends StatefulWidget {
  final VoidCallback onComplete;
  final Function(PrimerFlowState) onStateUpdate;
  final PrimerFlowState primerFlowState;

  const GrowthMessagePage({
    super.key,
    required this.onComplete,
    required this.onStateUpdate,
    required this.primerFlowState,
  });

  @override
  State<GrowthMessagePage> createState() => _GrowthMessagePageState();
}

class _GrowthMessagePageState extends State<GrowthMessagePage> {
  late final SessionRepository _sessionRepository;
  late final IconData _accentIcon;
  bool _isLoading = true;
  bool _isCompleting = false;
  String? _errorMessage;
  GrowthMessageDto? _growthMessage;

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _accentIcon = _pickAccentIcon();
    _loadGrowthMessage();
  }

  IconData _pickAccentIcon() {
    final icons = [
      Icons.favorite_border_rounded,
      Icons.wb_sunny_outlined,
      Icons.sentiment_satisfied_alt_outlined,
    ];
    return icons[math.Random().nextInt(icons.length)];
  }

  Future<void> _loadGrowthMessage() async {
    try {
      final message = await _sessionRepository.getRandomGrowthMessage(
        type: GrowthMessageType.begin,
      );

      if (!mounted) return;

      setState(() {
        _growthMessage = message;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = '${context.l10n.failedLoadGrowthMessage}: $e';
      });
    }
  }

  Future<void> _continueToNextAndCompletePrimer() async {
    if (_growthMessage == null) {
      return;
    }

    setState(() => _isCompleting = true);

    try {
      final updatedState = widget.primerFlowState.copyWith(
        growthMessageId: _growthMessage!.messageId,
      );

      widget.onStateUpdate(updatedState);

      if (updatedState.selectedStatementId == null ||
          updatedState.growthMessageId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.missingPrimerData),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isCompleting = false);
        }
        return;
      }

      final completePrimerDto = CompletePrimerDto(
        isSkipped: false,
        presentedStatementIds: updatedState.presentedStatementIds,
        selectedStatementId: updatedState.selectedStatementId,
        growthMessageId: updatedState.growthMessageId,
      );

      await _sessionRepository.completePrimerWithData(completePrimerDto);

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorCompletingPrimer(e.toString())),
            backgroundColor: Colors.red,
          ),
        );

        setState(() => _isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9F3),
        appBar: AppTopBar(
          title: context.l10n.dailySession,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B9B6E)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9F3),
        appBar: AppTopBar(
          title: context.l10n.dailySession,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.errorLoadingMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B9B6E),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadGrowthMessage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                ),
                child: Text(
                  context.l10n.retry,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppTopBar(
        title: context.l10n.dailySession,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GrowthBackgroundPainter(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    context.l10n.growthMessageTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B9B6E),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double topYFrac = 0.24;
                      const double midYFrac = 0.62;
                      final double centerY =
                          constraints.maxHeight * ((topYFrac + midYFrac) / 2);

                      final String messageText = _growthMessage?.text ??
                          context.l10n.loadingPersonalizedMessage;
                      final TextStyle messageStyle = GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B9B6E),
                        height: 1.5,
                      );

                      final TextPainter textPainter = TextPainter(
                        text: TextSpan(text: messageText, style: messageStyle),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        maxLines: null,
                      )..layout(
                          maxWidth:
                              constraints.maxWidth - (AppSpacing.lg * 2),
                        );

                      const double iconSize = 40;
                      const double iconSpacing = AppSpacing.md;
                      final double blockHeight =
                          textPainter.height + iconSpacing + iconSize;
                      final double topPadding =
                          math.max(0, centerY - (blockHeight / 2));
                      final double bottomPadding = math.max(
                        0,
                        constraints.maxHeight - topPadding - blockHeight,
                      );

                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          topPadding,
                          AppSpacing.lg,
                          bottomPadding,
                        ),
                        child: Column(
                          children: [
                            Text(
                              messageText,
                              textAlign: TextAlign.center,
                              style: messageStyle,
                            ),
                            const SizedBox(height: iconSpacing),
                            Icon(
                              _accentIcon,
                              size: iconSize,
                              color: const Color(0xFF6B9B6E)
                                  .withValues(alpha: 0.85),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isCompleting
                          ? null
                          : _continueToNextAndCompletePrimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B9B6E),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFBBBBBB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCompleting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              context.l10n.completePrimer,
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthBackgroundPainter extends CustomPainter {
  static const Color _baseGreen = Color(0xFF6B9B6E);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final double topY = height * 0.24;
    final double midY = height * 0.62;
    final double amplitude = height * 0.06;

    final Path fillPath = Path();
    fillPath.moveTo(0, topY);
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
        Paint()..color = _baseGreen.withValues(alpha: 0.22);
    canvas.drawPath(fillPath, fillPaint);

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _baseGreen.withValues(alpha: 0.55);

    final List<double> edgeOffsets = [0, 10, 20];
    for (final offset in edgeOffsets) {
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

    final Path bottomEdge = Path();
    for (double x = 0; x <= width; x += 10) {
      final double wave =
          math.sin((x / width) * math.pi * 2 + math.pi / 2) *
              (amplitude * 0.4);
      if (x == 0) {
        bottomEdge.moveTo(x, midY + height * 0.22 + wave);
      } else {
        bottomEdge.lineTo(x, midY + height * 0.22 + wave);
      }
    }
    canvas.drawPath(
      bottomEdge,
      linePaint..color = _baseGreen.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

