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
  final List<String> developedSkillIds;

  const EndGrowthMessagePage({
    super.key,
    required this.onComplete,
    this.developedSkillIds = const [],
  });

  @override
  State<EndGrowthMessagePage> createState() => _EndGrowthMessagePageState();
}

class _EndGrowthMessagePageState extends State<EndGrowthMessagePage> {
  late final SessionRepository _sessionRepository;
  late final PageController _pageController;
  bool _isLoading = true;
  String? _errorMessage;
  GrowthMessageDto? _growthMessage;
  String? _activePracticeLang;
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        developedSkillIds: _normalizedSkillIds(),
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

  List<String> _normalizedSkillIds() {
    final normalized = widget.developedSkillIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    return normalized;
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
    final messageParts = _resolvePrefixAndDescription(messageText);
    final cards = [messageParts.$1, messageParts.$2];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 700;
        final horizontalPadding = isCompact ? AppSpacing.md : AppSpacing.lg;
        final cardPadding = isCompact ? AppSpacing.lg : AppSpacing.xl;
        final titleSize = isCompact ? 24.0 : 28.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: isCompact ? AppSpacing.xs : AppSpacing.sm),
            Text(
              context.l10n.growthMessageTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B9B6E),
              ),
            ),
            SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: cardPadding,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.92),
                      const Color(0xFFEAF2E6).withValues(alpha: 0.86),
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
                      size: isCompact ? 28 : 32,
                      color: const Color(0xFF6B9B6E).withValues(alpha: 0.85),
                    ),
                    SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: cards.length,
                        onPageChanged: (index) {
                          if (!mounted) return;
                          setState(() => _currentCardIndex = index);
                        },
                        itemBuilder: (context, index) {
                          return _AdaptiveMessageText(text: cards[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${_currentCardIndex + 1}/2',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B9B6E).withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentCardIndex == 0) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    );
                    return;
                  }
                  widget.onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _currentCardIndex == 0
                      ? (_currentPracticeLang() == 'en' ? 'Continue' : 'Nastavite')
                      : context.l10n.continueToDashboard,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
          ],
        );
      },
    );
  }

  (String, String) _resolvePrefixAndDescription(String fullText) {
    final apiPrefix = _growthMessage?.prefix?.trim() ?? '';
    final apiDescription = _growthMessage?.description?.trim() ?? '';
    if (apiPrefix.isNotEmpty && apiDescription.isNotEmpty) {
      return (apiPrefix, apiDescription);
    }

    final normalized = fullText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return ('', '');
    }

    // Frontend-only fallback: split message into two balanced cards by sentence count.
    final sentenceRegex = RegExp(r'[^.!?]+[.!?]+|[^.!?]+$');
    final sentences = sentenceRegex
        .allMatches(normalized)
        .map((m) => m.group(0)!.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (sentences.length >= 2) {
      final firstCount = (sentences.length / 2).ceil();
      final firstPart = sentences.take(firstCount).join(' ').trim();
      final secondPart = sentences.skip(firstCount).join(' ').trim();
      if (firstPart.isNotEmpty && secondPart.isNotEmpty) {
        return (firstPart, secondPart);
      }
    }

    // If sentence detection fails, split by words to avoid duplicate cards.
    final words = normalized.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      final firstCount = (words.length / 2).ceil();
      final firstPart = words.take(firstCount).join(' ').trim();
      final secondPart = words.skip(firstCount).join(' ').trim();
      if (firstPart.isNotEmpty && secondPart.isNotEmpty) {
        return (firstPart, secondPart);
      }
    }

    return (normalized, normalized);
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

class _AdaptiveMessageText extends StatelessWidget {
  final String text;

  const _AdaptiveMessageText({required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseStyle = GoogleFonts.quicksand(
          fontSize: constraints.maxHeight < 280 ? 16 : 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2F3A2F),
          height: 1.55,
        );
        return Scrollbar(
          thumbVisibility: false,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: baseStyle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
