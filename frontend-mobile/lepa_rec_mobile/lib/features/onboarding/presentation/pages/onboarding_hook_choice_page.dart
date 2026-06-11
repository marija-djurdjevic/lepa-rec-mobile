import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';

class OnboardingHookChoicePage extends StatefulWidget {
  const OnboardingHookChoicePage({super.key});

  @override
  State<OnboardingHookChoicePage> createState() => _OnboardingHookChoicePageState();
}

class _OnboardingHookChoicePageState extends State<OnboardingHookChoicePage> {
  final _local = OnboardingLocalDataSource();
  final _remote = OnboardingRemoteDataSource();

  bool _loading = false;
  String? _error;
  String? _selectedHookType;

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';

  Future<void> _continue() async {
    final selected = _selectedHookType;
    if (selected == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final sessionId = await _local.readSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Missing onboarding session id');
      }

      await _remote.setHook(
        onboardingSessionId: sessionId,
        hookType: selected,
      );

      if (!mounted) return;
      final nextRoute = selected == 'DistancedJournal'
          ? '/onboarding/distanced-journal'
          : '/onboarding/perspective-scenario';
      Navigator.of(context).pushNamed(nextRoute);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _isEnglish
            ? 'Could not save your choice. Please try again.'
            : 'Nismo uspjeli da sacuvamo izbor. Pokušaj ponovo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final continueLabel = context.l10n.onboardingStoryContinue;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF6FBF4), Color(0xFFE9F4E8)],
              ),
            ),
          ),
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFB9D8BC).withValues(alpha: 0.24),
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
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.xl),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: Text(
                                  _buildSplitTitle(context.l10n.onboardingHookChoiceTitle),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 23,
                                    height: 1.28,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF5F8362),
                                    letterSpacing: 0.1,
                                  ),
                                  strutStyle: const StrutStyle(
                                    height: 1.28,
                                    leading: 0.12,
                                    forceStrutHeight: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          const SizedBox(height: AppSpacing.lg),
                          _buildOptionCard(
                            hookType: 'DistancedJournal',
                            title: context.l10n.onboardingHookChoiceSelfTitle,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildOptionCard(
                            hookType: 'PerspectiveScenario',
                            title: context.l10n.onboardingHookChoiceOthersTitle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFE9F4E8).withValues(alpha: 0),
                          const Color(0xFFE9F4E8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading || _selectedHookType == null ? null : _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B9B6E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          continueLabel,
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
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String hookType,
    required String title,
  }) {
    final selected = _selectedHookType == hookType;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutQuart,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF476149).withValues(alpha: selected ? 0.11 : 0.05),
            blurRadius: selected ? 18 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: selected ? const Color(0xFFE7F3E7) : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _loading ? null : () => setState(() => _selectedHookType = hookType),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? const Color(0xFF6B9B6E) : const Color(0xFFE1E9E1),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.quicksand(
                          fontSize: 17,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF628864),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected ? const Color(0xFF6B9B6E) : const Color(0xFF8EA28E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSplitTitle(String text) {
    // Keep onboarding heading cadence as two sentence blocks:
    // sentence 1, then an intentional blank line before sentence 2.
    final splitIndex = _firstSentenceEnd(text);
    if (splitIndex <= 0 || splitIndex >= text.length) return text;

    final firstPart = text.substring(0, splitIndex).trim();
    final secondPart = text.substring(splitIndex).trim();
    if (secondPart.isEmpty) return firstPart;
    return '$firstPart\n\n$secondPart';
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

