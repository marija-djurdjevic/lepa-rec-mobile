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
    final continueLabel = _isEnglish ? 'Continue' : 'Nastavite';
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    context.l10n.onboardingHookChoiceTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B9B6E),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildOptionCard(
                    hookType: 'DistancedJournal',
                    title: context.l10n.distancedJournal,
                    description: context.l10n.onboardingDistancedJournalDescription,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildOptionCard(
                    hookType: 'PerspectiveScenario',
                    title: context.l10n.perspectiveScenario,
                    description: context.l10n.onboardingPerspectiveScenarioDescription,
                  ),
                  const Spacer(),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  SizedBox(
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
    required String description,
  }) {
    final selected = _selectedHookType == hookType;

    return Material(
      color: selected ? const Color(0xFFE3F0E3) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _loading ? null : () => setState(() => _selectedHookType = hookType),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF6B9B6E) : const Color(0xFFD4DED4),
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
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4E6650),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5C735E),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? const Color(0xFF6B9B6E) : const Color(0xFF8EA28E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

