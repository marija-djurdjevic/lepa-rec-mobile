import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/dtos/onboarding_distanced_journal_challenge_dto.dart';
import 'package:lepa_rec_mobile/features/onboarding/presentation/models/onboarding_distanced_journal_follow_up_args.dart';

class OnboardingDistancedJournalPage extends StatefulWidget {
  const OnboardingDistancedJournalPage({super.key});

  @override
  State<OnboardingDistancedJournalPage> createState() => _OnboardingDistancedJournalPageState();
}

class _OnboardingDistancedJournalPageState extends State<OnboardingDistancedJournalPage> {
  final _remote = OnboardingRemoteDataSource();
  final _local = OnboardingLocalDataSource();
  final _controller = TextEditingController();

  bool _loading = true;
  bool _submitting = false;
  String? _error;

  OnboardingDistancedJournalChallengeDto? _challenge;
  String? _exerciseId;
  String? _sessionId;

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final lang = _isEnglish ? 'en' : 'sr';
      final sessionId = await _local.readSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Missing onboarding session id');
      }

      final challenge = await _remote.getDistancedJournalChallenge(
        onboardingSessionId: sessionId,
        lang: lang,
      );
      final exercise = await _remote.startDistancedJournal(
        onboardingSessionId: sessionId,
        challengeId: challenge.id,
      );

      if (!mounted) return;
      setState(() {
        _sessionId = sessionId;
        _challenge = challenge;
        _exerciseId = exercise.id;
      });
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

  Future<void> _continue() async {
    final answer = _controller.text.trim();
    if (answer.isEmpty) {
      setState(() => _error = context.l10n.answerRequired);
      return;
    }

    final challenge = _challenge;
    final sessionId = _sessionId;
    final exerciseId = _exerciseId;
    if (challenge == null || sessionId == null || exerciseId == null) {
      setState(() => _error = context.l10n.unknownError);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final args = OnboardingDistancedJournalFollowUpArgs(
      onboardingSessionId: sessionId,
      exerciseId: exerciseId,
      mainAnswer: answer,
      followUpQuestion: challenge.followUpQuestion,
    );

    if (!mounted) return;
    await Navigator.of(context).pushNamed('/onboarding/distanced-journal/follow-up', arguments: args);

    if (mounted) {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final challenge = _challenge;
    if (challenge == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(_error ?? context.l10n.unknownError),
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
                onPressed: _submitting ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  _isEnglish ? 'Continue' : 'Nastavite',
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
                  challenge.content,
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
