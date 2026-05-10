import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/core/network/api_client.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:lepa_rec_mobile/l10n/app_localizations.dart';
import 'package:lepa_rec_mobile/main.dart';

class OnboardingLanguagePage extends StatefulWidget {
  const OnboardingLanguagePage({super.key});

  @override
  State<OnboardingLanguagePage> createState() => _OnboardingLanguagePageState();
}

class _OnboardingLanguagePageState extends State<OnboardingLanguagePage> {
  final _remote = OnboardingRemoteDataSource();
  final _local = OnboardingLocalDataSource();

  bool _loading = false;
  String? _error;
  String? _selectedLanguage;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    _selectedLanguage = _normalizedCurrentLanguage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSkipWhenSingleLanguage());
  }

  String _normalizedCurrentLanguage() {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'en' ? 'en' : 'sr';
  }

  List<String> _availableLanguages() {
    final languageCodes = <String>{};
    for (final locale in AppLocalizations.supportedLocales) {
      languageCodes.add(locale.languageCode == 'en' ? 'en' : 'sr');
    }
    return languageCodes.toList();
  }

  Future<void> _autoSkipWhenSingleLanguage() async {
    final langs = _availableLanguages();
    if (langs.length != 1) return;

    final onlyLanguage = langs.first;
    setState(() {
      _selectedLanguage = onlyLanguage;
    });

    await _submitLanguage(onlyLanguage);
  }

  Future<void> _submitLanguage(String preferredLanguage) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final appState = LepaRecApp.maybeOf(context);
      final sessionId = await _local.readSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Missing onboarding session id');
      }

      await _remote.setLanguage(
        onboardingSessionId: sessionId,
        preferredLanguage: preferredLanguage,
      );

      ApiClient.setLanguageCode(preferredLanguage);
      await appState?.changeLanguage(preferredLanguage);

      if (!mounted) return;
      Navigator.of(context).pushNamed('/onboarding/hook-choice');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.unknownError;
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
    final isEnglishSelected = _selectedLanguage == 'en';
    final continueLabel = Localizations.localeOf(context).languageCode == 'en'
        ? 'Continue'
        : 'Nastavite';

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
                    context.l10n.language,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B9B6E),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLanguageOption(
                    label: context.l10n.languageEnglish,
                    selected: isEnglishSelected,
                    onTap: () => setState(() => _selectedLanguage = 'en'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildLanguageOption(
                    label: context.l10n.languageSerbian,
                    selected: !isEnglishSelected,
                    onTap: () => setState(() => _selectedLanguage = 'sr'),
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
                      onPressed: _loading || _selectedLanguage == null
                          ? null
                          : () => _submitLanguage(_selectedLanguage!),
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

  Widget _buildLanguageOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? const Color(0xFFE3F0E3) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _loading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF6B9B6E)
                  : const Color(0xFFD4DED4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4E6650),
                  ),
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? const Color(0xFF6B9B6E)
                    : const Color(0xFF8EA28E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

