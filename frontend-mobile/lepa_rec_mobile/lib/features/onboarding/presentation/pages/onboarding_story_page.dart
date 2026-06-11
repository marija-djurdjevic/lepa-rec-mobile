import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';

class OnboardingStoryPage extends StatefulWidget {
  const OnboardingStoryPage({super.key});

  @override
  State<OnboardingStoryPage> createState() => _OnboardingStoryPageState();
}

class _OnboardingStoryPageState extends State<OnboardingStoryPage> {
  static const _storyFadeDuration = Duration(milliseconds: 300);
  int _currentIndex = 0;
  bool _isTransitioning = false;
  bool _isStoryVisible = true;

  Future<void> _goBack() async {
    if (_currentIndex == 0 || _isTransitioning) return;
    setState(() {
      _isTransitioning = true;
    });
    await _switchStoryTo(_currentIndex - 1);
    if (mounted) {
      setState(() {
        _isTransitioning = false;
      });
    }
  }

  Future<void> _goNext() async {
    if (_isTransitioning) return;
    if (_currentIndex < 2) {
      setState(() {
        _isTransitioning = true;
      });
      await _switchStoryTo(_currentIndex + 1);
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
      return;
    }

    Navigator.of(context).pushNamed('/onboarding/hook-choice');
  }

  Future<void> _switchStoryTo(int nextIndex) async {
    setState(() {
      _isStoryVisible = false;
    });
    await Future<void>.delayed(_storyFadeDuration);
    if (!mounted) return;

    setState(() {
      _currentIndex = nextIndex;
      _isStoryVisible = true;
    });
    await Future<void>.delayed(_storyFadeDuration);
  }

  @override
  Widget build(BuildContext context) {
    final stories = [
      context.l10n.onboardingStoryHook,
      context.l10n.onboardingStorySkill,
      context.l10n.onboardingStoryHabit,
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FBF4), Color(0xFFEAF4E8)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFB6D5B8).withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8EAD9).withValues(alpha: 0.38),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _ProgressDots(currentIndex: _currentIndex, total: stories.length),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: Center(
                        child: AnimatedOpacity(
                          duration: _storyFadeDuration,
                          curve: Curves.easeInOut,
                          opacity: _isStoryVisible ? 1 : 0,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.86),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: const Color(0xFFCFE2CF),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isCompact = constraints.maxWidth < 360;
                                return Text.rich(
                                  _storyTextSpan(
                                    text: stories[_currentIndex],
                                    isCompact: isCompact,
                                  ),
                                  textAlign: TextAlign.start,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _currentIndex == 0 || _isTransitioning
                                  ? null
                                  : () => _goBack(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF6B9B6E)),
                                backgroundColor: Colors.white.withValues(alpha: 0.72),
                                disabledForegroundColor: const Color(0xFF9DB19E),
                                disabledBackgroundColor: Colors.white.withValues(alpha: 0.45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                context.l10n.onboardingStoryBack,
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _currentIndex == 0 || _isTransitioning
                                      ? const Color(0xFF9DB19E)
                                      : const Color(0xFF4E6650),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isTransitioning ? null : () => _goNext(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B9B6E),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFF9DB19E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                context.l10n.onboardingStoryContinue,
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InlineSpan _storyTextSpan({
    required String text,
    required bool isCompact,
  }) {
    final baseStyle = GoogleFonts.quicksand(
      fontSize: isCompact ? 18 : 20,
      height: 1.55,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF4E6650),
    );

    final firstSentenceEnd = _firstSentenceEnd(text);
    final head = text.substring(0, firstSentenceEnd).trim();
    final tail = text.substring(firstSentenceEnd).trimLeft();

    return TextSpan(
      style: baseStyle,
      children: [
        TextSpan(
          text: head,
          style: baseStyle.copyWith(
            fontSize: isCompact ? 19.5 : 22,
            height: 1.45,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E4A33),
          ),
        ),
        if (tail.isNotEmpty) TextSpan(text: '\n\n$tail'),
      ],
    );
  }

  int _firstSentenceEnd(String text) {
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '.' || char == '!' || char == '?') {
        return i + 1;
      }
    }
    return text.length;
  }
}

class _ProgressDots extends StatelessWidget {
  final int currentIndex;
  final int total;

  const _ProgressDots({
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutQuart,
          width: index == currentIndex ? 30 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == currentIndex
                ? const Color(0xFF6B9B6E)
                : const Color(0xFFD4DED4),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}
