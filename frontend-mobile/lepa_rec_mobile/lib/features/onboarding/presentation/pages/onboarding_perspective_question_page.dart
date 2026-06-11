import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/core/constants/app_spacing.dart';
import 'package:lepa_rec_mobile/core/localization/localization_extension.dart';
import 'package:lepa_rec_mobile/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:lepa_rec_mobile/features/onboarding/presentation/models/onboarding_perspective_question_args.dart';
import 'package:lepa_rec_mobile/features/sessions/data/dtos/perspective_scenario_question_dto.dart';

class OnboardingPerspectiveQuestionPage extends StatefulWidget {
  const OnboardingPerspectiveQuestionPage({super.key});

  @override
  State<OnboardingPerspectiveQuestionPage> createState() =>
      _OnboardingPerspectiveQuestionPageState();
}

class _OnboardingPerspectiveQuestionPageState
    extends State<OnboardingPerspectiveQuestionPage> {
  final _remote = OnboardingRemoteDataSource();
  final _scrollController = ScrollController();
  final _answersByQuestionId = <String, String>{};
  final _revealsByQuestionId = <String, String>{};

  List<PerspectiveScenarioQuestionDto> _questions = const [];
  List<TextEditingController> _controllers = const [];
  String? _initializedExerciseId;
  int _visibleQuestionCount = 0;
  bool _submitting = false;
  bool _showValidationErrors = false;
  bool _isExerciseCompleted = false;
  String? _error;

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureInitialized(OnboardingPerspectiveQuestionArgs args) {
    if (_initializedExerciseId == args.exerciseId) return;

    for (final controller in _controllers) {
      controller.dispose();
    }

    _questions = [...args.challenge.questions]
      ..sort((a, b) => a.order.compareTo(b.order));
    _controllers = _questions.map((_) => TextEditingController()).toList();
    _answersByQuestionId
      ..clear()
      ..addAll(args.answersByQuestionId);

    for (var i = 0; i < _questions.length; i++) {
      final answer = _answersByQuestionId[_questions[i].id];
      if (answer != null && answer.isNotEmpty) {
        _controllers[i].text = answer;
      }
    }

    _revealsByQuestionId.clear();
    _visibleQuestionCount = _questions.isEmpty ? 0 : 1;
    _initializedExerciseId = args.exerciseId;
    _isExerciseCompleted = false;
    _showValidationErrors = false;
    _error = null;
  }

  Future<void> _handleContinue(
    OnboardingPerspectiveQuestionArgs args,
    int index,
  ) async {
    final question = _questions[index];
    final hasReveal = _hasRevealForQuestion(question);

    if (_isExerciseCompleted && _isLastQuestion(index)) {
      _goToRegistration();
      return;
    }

    if (hasReveal) {
      if (_isLastQuestion(index)) {
        _goToRegistration();
        return;
      }

      if (_visibleQuestionCount < _questions.length) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        setState(() {
          _visibleQuestionCount += 1;
          _error = null;
        });
        _scrollToBottom();
      }
      return;
    }

    await _answerAndReveal(args, index);
  }

  Future<void> _answerAndReveal(
    OnboardingPerspectiveQuestionArgs args,
    int index,
  ) async {
    final question = _questions[index];
    final answer = _controllers[index].text.trim();
    if (answer.isEmpty) {
      setState(() {
        _showValidationErrors = true;
        _error = context.l10n.answerRequired;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _showValidationErrors = false;
      _error = null;
    });

    try {
      final response = await _remote.answerPerspectiveAndReveal(
        onboardingSessionId: args.onboardingSessionId,
        exerciseId: args.exerciseId,
        questionId: question.id,
        answerText: answer,
        lang: _isEnglish ? 'en' : 'sr',
      );

      if (!mounted) return;
      setState(() {
        _answersByQuestionId[question.id] = answer;
        if (response.reveal.trim().isNotEmpty) {
          _revealsByQuestionId[question.id] = response.reveal.trim();
        }
        _isExerciseCompleted = response.isExerciseCompleted;
        _submitting = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _isEnglish
            ? 'Could not fetch reveal. Please try again.'
            : 'Nismo uspjeli da dobijemo otkrivanje. Pokušajte ponovo.';
        _submitting = false;
      });
    }
  }

  void _goToRegistration() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/onboarding/register',
      (route) => false,
    );
  }

  bool _hasText(int index) => _controllers[index].text.trim().isNotEmpty;

  bool _isLastQuestion(int index) => index == _questions.length - 1;

  bool _hasRevealForQuestion(PerspectiveScenarioQuestionDto question) {
    return (_revealsByQuestionId[question.id] ?? '').trim().isNotEmpty;
  }

  bool _shouldShowContinueButton(int index) {
    if (index != _visibleQuestionCount - 1) return false;
    if (_isExerciseCompleted && _isLastQuestion(index)) return true;
    return _hasText(index) || _hasRevealForQuestion(_questions[index]);
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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! OnboardingPerspectiveQuestionArgs) {
      return Scaffold(body: Center(child: Text(context.l10n.unknownError)));
    }

    _ensureInitialized(args);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.perspectiveScenario,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B9B6E),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildScenarioCard(args),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.perspectiveScenarioDisclaimer,
                    style: GoogleFonts.quicksand(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < _visibleQuestionCount; i++) ...[
                    _buildQuestionSection(i),
                    if (_shouldShowContinueButton(i)) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submitting
                              ? null
                              : () => _handleContinue(args, i),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B9B6E),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            _buttonLabel(i),
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (_error != null) ...[
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
            ),
          ),
          if (_submitting)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  String _buttonLabel(int index) {
    if (_isExerciseCompleted && _isLastQuestion(index)) {
      return context.l10n.conclude;
    }
    if (_hasRevealForQuestion(_questions[index])) {
      return _isLastQuestion(index)
          ? context.l10n.conclude
          : context.l10n.continueToNext;
    }
    return _isLastQuestion(index) ? context.l10n.wrapUp : context.l10n.continueToNext;
  }

  Widget _buildScenarioCard(OnboardingPerspectiveQuestionArgs args) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2E3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            args.challenge.scenarioText,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4E6650),
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getLevelColor(args.challenge.challengeLevel),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getLevelLabel(args.challenge.challengeLevel),
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(int index) {
    final question = _questions[index];
    final controller = _controllers[index];
    final reveal = _revealsByQuestionId[question.id];
    final hasError = _showValidationErrors && controller.text.trim().isEmpty;
    final isReadOnly = _submitting || _hasRevealForQuestion(question);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          question.questionText,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4E6650),
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: controller,
          minLines: 8,
          maxLines: 14,
          enabled: !isReadOnly,
          onChanged: (_) {
            if (_showValidationErrors || index == _visibleQuestionCount - 1) {
              setState(() {});
            }
          },
          decoration: InputDecoration(
            hintText: context.l10n.shareYourThoughts,
            hintStyle: GoogleFonts.quicksand(
              color: const Color(0xFF9AA99B),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFCF9),
            border: _inputBorder(hasError),
            enabledBorder: _inputBorder(hasError),
            focusedBorder: _inputBorder(hasError, focused: true),
            disabledBorder: _inputBorder(false),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              context.l10n.answerRequired,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        if (reveal != null && reveal.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildRevealCard(reveal),
        ],
      ],
    );
  }

  OutlineInputBorder _inputBorder(bool hasError, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: hasError
            ? Colors.red
            : focused
            ? const Color(0xFF6B9B6E)
            : const Color(0xFFD9E5D7),
        width: focused ? 1.4 : 1,
      ),
    );
  }

  Widget _buildRevealCard(String reveal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF6B9B6E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6B9B6E), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 22,
                color: Color(0xFF6B9B6E),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.perspectiveRevealTitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B9B6E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            reveal,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2F3A2F),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.perspectiveRevealHint,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF6B9B6E),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
      case 'lako':
        return const Color(0xFF8BBF8F);
      case 'medium':
      case 'umereno':
        return const Color(0xFF5C9A6B);
      case 'hard':
      case 'tesko':
      case 'teško':
        return const Color(0xFF3E7A52);
      default:
        return const Color(0xFF6B9B6E);
    }
  }

  String _getLevelLabel(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
      case 'lako':
        return context.l10n.levelEasy;
      case 'medium':
      case 'umereno':
        return context.l10n.levelMedium;
      case 'hard':
      case 'tesko':
      case 'teško':
        return context.l10n.levelHard;
      default:
        return level;
    }
  }
}
