import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../data/dtos/growth_message_dto.dart';
import '../../data/dtos/growth_message_type.dart';
import '../../data/repositories/session_repository.dart';

class EndGrowthMessagePage extends StatefulWidget {
  final VoidCallback onComplete;

  const EndGrowthMessagePage({super.key, required this.onComplete});

  @override
  State<EndGrowthMessagePage> createState() => _EndGrowthMessagePageState();
}

class _EndGrowthMessagePageState extends State<EndGrowthMessagePage> {
  late final SessionRepository _sessionRepository;
  bool _isLoading = true;
  String? _errorMessage;
  GrowthMessageDto? _growthMessage;
  String? _activePracticeLang;

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = _currentPracticeLang();
    if (_activePracticeLang == currentLang) return;
    _activePracticeLang = currentLang;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadGrowthMessage();
  }

  Future<void> _loadGrowthMessage() async {
    try {
      final message = await _sessionRepository.getRandomGrowthMessage(
        type: GrowthMessageType.end,
        lang: _currentPracticeLang(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF5F9F3),
                      const Color(0xFFE8F2E2),
                      const Color(0xFFF7F3EA),
                    ],
                    stops: const [0.15, 0.55, 0.95],
                  ),
                ),
              ),
            ),
            const Positioned(
              top: -80,
              left: -40,
              child: _GlowOrb(size: 190, opacity: 0.45),
            ),
            const Positioned(
              bottom: -90,
              right: -30,
              child: _GlowOrb(size: 210, opacity: 0.35),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _HaloPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6B9B6E),
                        ),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.errorLoadingMessage,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B9B6E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage ?? '',
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
    );
  }

  Widget _buildContent() {
    final messageText = _growthMessage?.text ??
        context.l10n.loadingPersonalizedMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.growthMessageTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6B9B6E),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      const Color(0xFFEAF2E6).withValues(alpha: 0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF6B9B6E).withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 32,
                      color: const Color(0xFF6B9B6E)
                          .withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      messageText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F3A2F),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: widget.onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9B6E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              context.l10n.continueToDashboard,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  String _currentPracticeLang() {
    return Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr';
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowOrb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFB8D6B6).withValues(alpha: opacity),
            const Color(0xFFB8D6B6).withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _HaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.44);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF6B9B6E).withValues(alpha: 0.18);

    for (var i = 0; i < 3; i++) {
      final radius = size.width * (0.26 + (i * 0.07));
      final path = Path();
      for (double angle = 0; angle <= 360; angle += 4) {
        final radians = angle * (math.pi / 180);
        final wobble = math.sin(radians * 2.6) * (6 + (i * 2.5));
        final point = Offset(
          center.dx + math.cos(radians) * (radius + wobble),
          center.dy + math.sin(radians) * (radius + wobble),
        );
        if (angle == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
