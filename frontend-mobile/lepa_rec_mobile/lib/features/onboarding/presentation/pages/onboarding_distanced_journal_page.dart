import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/dtos/onboarding_distanced_journal_challenge_dto.dart';

class OnboardingDistancedJournalPage extends StatefulWidget {
  const OnboardingDistancedJournalPage({super.key});

  @override
  State<OnboardingDistancedJournalPage> createState() =>
      _OnboardingDistancedJournalPageState();
}

class _OnboardingDistancedJournalPageState
    extends State<OnboardingDistancedJournalPage> {
  final _remote = OnboardingRemoteDataSource();
  final _local = OnboardingLocalDataSource();
  final _mainAnswerController = TextEditingController();
  final _followUpAnswerController = TextEditingController();
  final _personaNameController = TextEditingController();
  final _generatedReflectionAnswerController = TextEditingController();
  final _scrollController = ScrollController();

  bool _loading = true;
  bool _submitting = false;
  bool _showFollowUpQuestion = false;
  bool _journalSubmitted = false;
  bool _showGeneratedReflectionQuestion = false;
  bool _savingGeneratedReflection = false;
  String? _error;
  String? _generatedReflectionQuestion;

  OnboardingDistancedJournalChallengeDto? _challenge;
  String? _exerciseId;
  String? _sessionId;

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';
  bool get _hasMainAnswer => _mainAnswerController.text.trim().isNotEmpty;
  bool get _hasGeneratedReflectionAnswer =>
      _generatedReflectionAnswerController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _mainAnswerController.addListener(_onAnswerChanged);
    _followUpAnswerController.addListener(_onAnswerChanged);
    _generatedReflectionAnswerController.addListener(_onAnswerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  void _onAnswerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _mainAnswerController.removeListener(_onAnswerChanged);
    _followUpAnswerController.removeListener(_onAnswerChanged);
    _generatedReflectionAnswerController.removeListener(_onAnswerChanged);
    _mainAnswerController.dispose();
    _followUpAnswerController.dispose();
    _personaNameController.dispose();
    _generatedReflectionAnswerController.dispose();
    _scrollController.dispose();
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
    if (!_hasMainAnswer) {
      setState(() => _error = context.l10n.answerRequired);
      return;
    }

    setState(() {
      _error = null;
      _showFollowUpQuestion = true;
    });

    _scrollToBottom();
  }

  Future<void> _submit() async {
    final mainAnswer = _mainAnswerController.text.trim();
    final followUpAnswer = _followUpAnswerController.text.trim();
    if (mainAnswer.isEmpty || followUpAnswer.isEmpty) {
      setState(() => _error = context.l10n.answerRequired);
      return;
    }

    final sessionId = _sessionId;
    final exerciseId = _exerciseId;
    if (sessionId == null || exerciseId == null) {
      setState(() => _error = context.l10n.unknownError);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await _remote.submitDistancedJournal(
        onboardingSessionId: sessionId,
        exerciseId: exerciseId,
        sessionDate: DateTime.now().toUtc(),
        mainAnswer: mainAnswer,
        followUpAnswer: followUpAnswer,
      );

      if (!mounted) return;
      final generatedQuestion = result.generatedReflectionQuestion?.trim();
      if (generatedQuestion != null && generatedQuestion.isNotEmpty) {
        setState(() {
          _submitting = false;
          _journalSubmitted = true;
          _generatedReflectionQuestion = generatedQuestion;
          _showGeneratedReflectionQuestion = false;
          _generatedReflectionAnswerController.clear();
        });
        _scrollToBottom();
        return;
      }

      _goToRegistration();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
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
    final openingQuestion = challenge.openingQuestion.trim();
    final cardText = openingQuestion.isEmpty
        ? challenge.content
        : '${challenge.content}\n\n$openingQuestion';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
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
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardText,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4E6650),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.distancedJournalHint,
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildPersonaNameField(),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _mainAnswerController,
                minLines: 10,
                maxLines: null,
                enabled: !_submitting && !_journalSubmitted,
                decoration: InputDecoration(
                  hintText: context.l10n.shareYourThoughts,
                  hintStyle: GoogleFonts.quicksand(
                    color: const Color(0xFF9AA99B),
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFAFCF9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF6B9B6E),
                      width: 1.4,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
                  ),
                ),
              ),
              if (_showFollowUpQuestion) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F2E3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    challenge.followUpQuestion,
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
                  controller: _followUpAnswerController,
                  minLines: 10,
                  maxLines: null,
                  enabled: !_submitting && !_journalSubmitted,
                  decoration: InputDecoration(
                    hintText: context.l10n.shareYourThoughts,
                    hintStyle: GoogleFonts.quicksand(
                      color: const Color(0xFF9AA99B),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAFCF9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF6B9B6E),
                        width: 1.4,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              if (_hasMainAnswer) ...[
                const SizedBox(height: AppSpacing.md),
                if (_journalSubmitted)
                  _buildGeneratedReflectionInline()
                else
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : _showFollowUpQuestion
                          ? _submit
                          : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B9B6E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _showFollowUpQuestion
                            ? (_isEnglish ? 'Conclude' : 'Zaključite')
                            : (_isEnglish ? 'Wrap up' : 'Zaokružite'),
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitGeneratedReflection() async {
    final answer = _generatedReflectionAnswerController.text.trim();
    if (answer.isEmpty) {
      setState(() => _error = context.l10n.answerRequired);
      return;
    }

    _goToRegistration();
  }

  void _showGeneratedReflectionInline() {
    setState(() {
      _showGeneratedReflectionQuestion = true;
    });
    _scrollToBottom();
  }

  void _goToRegistration() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/onboarding/register', (route) => false);
  }

  Widget _buildGeneratedReflectionInline() {
    final question = _generatedReflectionQuestion?.trim();
    if (question == null || question.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!_showGeneratedReflectionQuestion) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.generatedReflectionOfferTitle,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _savingGeneratedReflection
                  ? null
                  : _showGeneratedReflectionInline,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9B6E),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.l10n.generatedReflectionShowQuestion,
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _savingGeneratedReflection ? null : _goToRegistration,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B9B6E),
                side: const BorderSide(color: Color(0xFF6B9B6E), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.l10n.generatedReflectionSkip,
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B9B6E),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _generatedReflectionAnswerController,
          minLines: 8,
          maxLines: null,
          enabled: !_savingGeneratedReflection,
          decoration: InputDecoration(
            hintText: context.l10n.generatedReflectionAnswerHint,
            hintStyle: GoogleFonts.quicksand(
              color: const Color(0xFF9AA99B),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFCF9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF6B9B6E),
                width: 1.4,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
                _savingGeneratedReflection || !_hasGeneratedReflectionAnswer
                ? null
                : _submitGeneratedReflection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9B6E),
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _savingGeneratedReflection
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[300]!,
                      ),
                    ),
                  )
                : Text(
                    context.l10n.conclude,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonaNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.distancedJournalPersonaLabel,
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4E6650),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _personaNameController,
          enabled: !_submitting && !_journalSubmitted,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: context.l10n.distancedJournalPersonaHint,
            hintStyle: GoogleFonts.quicksand(
              color: const Color(0xFF9AA99B),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFCF9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF6B9B6E),
                width: 1.4,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9E5D7)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          cursorColor: const Color(0xFF6B9B6E),
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2F3A2F),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.distancedJournalPersonaHelper,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
