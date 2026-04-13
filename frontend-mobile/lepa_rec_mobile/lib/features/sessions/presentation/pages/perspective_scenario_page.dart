import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/dtos/perspective_scenario_answer_dto.dart';
import '../../data/dtos/perspective_scenario_exercise_dto.dart';
import '../../data/dtos/perspective_scenario_prompt_dto.dart';
import '../../data/dtos/start_perspective_scenario_dto.dart';
import '../../data/dtos/submit_perspective_scenario_answer_dto.dart';
import '../../data/repositories/session_repository.dart';
import 'end_growth_message_page.dart';

class PerspectiveScenarioPage extends StatefulWidget {
  final PerspectiveScenarioPromptDto prompt;

  const PerspectiveScenarioPage({super.key, required this.prompt});

  @override
  State<PerspectiveScenarioPage> createState() =>
      _PerspectiveScenarioPageState();
}

class _PerspectiveScenarioPageState extends State<PerspectiveScenarioPage> {
  static const double _answerBoxHeight = 360;
  late final SessionRepository _sessionRepository;
  late final List<TextEditingController> _answerControllers;
  late final ScrollController _scrollController;

  PerspectiveScenarioExerciseDto? _exercise;
  int _visibleQuestionCount = 0;
  bool _isStarting = true;
  bool _isSubmitting = false;
  bool _showValidationErrors = false;
  String? _loadingError;
  String? _revealText;

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _answerControllers = widget.prompt.questions
        .map((_) => TextEditingController())
        .toList();
    _scrollController = ScrollController();
    _visibleQuestionCount = widget.prompt.questions.isEmpty ? 0 : 1;
    _startScenario();
  }

  @override
  void dispose() {
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startScenario() async {
    setState(() {
      _isStarting = true;
      _loadingError = null;
    });

    try {
      final startedExercise = await _sessionRepository.startPerspectiveScenario(
        StartPerspectiveScenarioDto(challengeId: widget.prompt.id),
      );

      if (!mounted) return;

      for (var i = 0; i < widget.prompt.questions.length; i++) {
        final questionId = widget.prompt.questions[i].id;
        PerspectiveScenarioAnswerDto? existingAnswer;
        for (final answer in startedExercise.answers) {
          if (answer.questionId == questionId) {
            existingAnswer = answer;
            break;
          }
        }
        _answerControllers[i].text = existingAnswer?.answerText ?? '';
      }

      _visibleQuestionCount = _calculateVisibleQuestionCount();

      setState(() {
        _exercise = startedExercise;
        _isStarting = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 404) {
        _showExerciseNotFound();
        Navigator.pop(context, true);
        return;
      }

      setState(() {
        _loadingError = e.toString();
        _isStarting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingError = e.toString();
        _isStarting = false;
      });
    }
  }

  bool _validateForm() {
    return _answerControllers.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
  }

  Future<void> _handleSubmit() async {
    if (_exercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.exerciseNotInitialized),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    if (!_validateForm()) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final answers = <PerspectiveScenarioAnswerDto>[];
      for (var i = 0; i < widget.prompt.questions.length; i++) {
        answers.add(
          PerspectiveScenarioAnswerDto(
            questionId: widget.prompt.questions[i].id,
            answerText: _answerControllers[i].text.trim(),
          ),
        );
      }

      final result = await _sessionRepository.submitPerspectiveScenario(
        SubmitPerspectiveScenarioAnswerDto(
          exerciseId: _exercise!.id,
          sessionDate: DateTime.now(),
          answers: answers,
        ),
      );

      if (!mounted) return;

      setState(() {
        _revealText = result.reveal;
        _isSubmitting = false;
      });
      _scrollToBottom();
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 404) {
        _showExerciseNotFound();
        Navigator.pop(context, true);
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.errorSubmittingPerspectiveScenario(e.toString()),
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.errorSubmittingPerspectiveScenario(e.toString()),
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9F3),
        elevation: 0,
        title: Text(
          context.l10n.perspectiveScenario,
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B9B6E),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B9B6E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  void _showExerciseNotFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.exerciseNotFoundOrOwned),
        backgroundColor: Colors.red[600],
      ),
    );
  }

  Widget _buildBody() {
    if (_isStarting) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B9B6E)),
        ),
      );
    }

    if (_loadingError != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.errorStartingExercise,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B9B6E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _loadingError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _startScenario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                ),
                child: Text(
                  context.l10n.retry,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B6E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF6B9B6E).withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.prompt.scenarioText,
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(widget.prompt.challengeLevel),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getLevelLabel(
                        widget.prompt.challengeLevel,
                        context,
                      ),
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < _visibleQuestionCount; i++) ...[
              _buildQuestionCard(i),
              if (_shouldShowContinueButton(i))
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _handleContinue(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B9B6E),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting && _isLastQuestion(i)
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey[300]!,
                                ),
                              ),
                            )
                          : Text(
                              context.l10n.wrapUp,
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (_revealText != null) ...[
              _buildRevealCard(_revealText!),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final messageCompleted = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EndGrowthMessagePage(
                          onComplete: () => Navigator.pop(context, true),
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (messageCompleted == true) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9B6E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.conclude,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = widget.prompt.questions[index];
    final controller = _answerControllers[index];
    final hasError = _showValidationErrors && controller.text.trim().isEmpty;
    final isReadOnly = _revealText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: _answerBoxHeight,
            child: TextField(
              controller: controller,
              maxLines: null,
              minLines: null,
              expands: true,
              enabled: !_isSubmitting && !isReadOnly,
              onChanged: (_) {
                if (_showValidationErrors ||
                    index == _visibleQuestionCount - 1) {
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                hintText: context.l10n.shareYourThoughts,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : Colors.grey[300]!,
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : Colors.grey[300]!,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : const Color(0xFF6B9B6E),
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1.2),
                ),
                filled: true,
                fillColor: const Color(0xFFF2F4F0),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
              ),
              cursorColor: const Color(0xFF6B9B6E),
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2F3A2F),
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
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
      ],
    );
  }

  int _calculateVisibleQuestionCount() {
    if (widget.prompt.questions.isEmpty) {
      return 0;
    }

    for (var i = 0; i < _answerControllers.length; i++) {
      if (_answerControllers[i].text.trim().isEmpty) {
        return i + 1;
      }
    }

    return _answerControllers.length;
  }

  bool _hasText(int index) {
    return _answerControllers[index].text.trim().isNotEmpty;
  }

  bool _isLastQuestion(int index) {
    return index == widget.prompt.questions.length - 1;
  }

  bool _shouldShowContinueButton(int index) {
    if (_revealText != null) {
      return false;
    }

    if (index != _visibleQuestionCount - 1) {
      return false;
    }

    return _hasText(index);
  }

  void _handleContinue(int index) async {
    if (!_hasText(index)) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }

    if (_isLastQuestion(index)) {
      _handleSubmit();
      return;
    }

    if (_visibleQuestionCount < widget.prompt.questions.length) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() {
        _visibleQuestionCount += 1;
      });
      _scrollToBottom();
    }
  }

  Widget _buildRevealCard(String reveal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF6B9B6E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B9B6E),
          width: 1.2,
        ),
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
                  softWrap: true,
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
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
        return const Color(0xFF3E7A52);
      default:
        return const Color(0xFF6B9B6E);
    }
  }

  String _getLevelLabel(String level, BuildContext context) {
    switch (level.toLowerCase()) {
      case 'easy':
      case 'lako':
        return context.l10n.levelEasy;
      case 'medium':
        case 'umereno':
          return context.l10n.levelMedium;
      case 'hard':
      case 'tesko':
        return context.l10n.levelHard;
      default:
        return level;
    }
  }
}
