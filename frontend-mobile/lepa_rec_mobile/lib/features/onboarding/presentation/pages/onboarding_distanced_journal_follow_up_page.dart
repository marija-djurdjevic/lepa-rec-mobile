import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/presentation/models/onboarding_distanced_journal_follow_up_args.dart';

class OnboardingDistancedJournalFollowUpPage extends StatefulWidget {
  const OnboardingDistancedJournalFollowUpPage({super.key});

  @override
  State<OnboardingDistancedJournalFollowUpPage> createState() => _OnboardingDistancedJournalFollowUpPageState();
}

class _OnboardingDistancedJournalFollowUpPageState extends State<OnboardingDistancedJournalFollowUpPage> {
  final _remote = OnboardingRemoteDataSource();
  final _controller = TextEditingController();

  bool _submitting = false;
  String? _error;

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(OnboardingDistancedJournalFollowUpArgs args) async {
    final followUpAnswer = _controller.text.trim();
    if (followUpAnswer.isEmpty) {
      setState(() => _error = context.l10n.answerRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _remote.submitDistancedJournal(
        onboardingSessionId: args.onboardingSessionId,
        exerciseId: args.exerciseId,
        sessionDate: DateTime.now().toUtc(),
        mainAnswer: args.mainAnswer,
        followUpAnswer: followUpAnswer,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/onboarding/register', (route) => false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _isEnglish
            ? 'Could not submit your answers. Please try again.'
            : 'Nismo uspjeli da pošaljemo odgovore. Pokušajte ponovo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! OnboardingDistancedJournalFollowUpArgs) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(context.l10n.unknownError),
          ),
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: AppSpacing.md),
            ],
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : () => _submit(args),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  _isEnglish ? 'Conclude' : 'Zaključi',
                  style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl + AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.distancedJournal,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B9B6E),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2E3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Text(
                  args.followUpQuestion,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4E6650),
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                minLines: 8,
                maxLines: 14,
                enabled: !_submitting,
                decoration: InputDecoration(
                  hintText: context.l10n.shareYourThoughts,
                  filled: true,
                  fillColor: const Color(0xFFFAFCF9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
