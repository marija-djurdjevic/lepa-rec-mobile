import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/dtos/perspective_scenario_answer_dto.dart';
import '../../data/dtos/perspective_scenario_exercise_dto.dart';
import '../../data/dtos/perspective_scenario_prompt_dto.dart';
import '../../data/dtos/start_perspective_scenario_dto.dart';
import '../../data/dtos/submit_perspective_scenario_answer_dto.dart';
import '../../data/repositories/session_repository.dart';
import 'perspective_scenario_reveal_page.dart';

class PerspectiveScenarioPage extends StatefulWidget {
  final PerspectiveScenarioPromptDto prompt;

  const PerspectiveScenarioPage({super.key, required this.prompt});

  @override
  State<PerspectiveScenarioPage> createState() =>
      _PerspectiveScenarioPageState();
}

class _PerspectiveScenarioPageState extends State<PerspectiveScenarioPage> {
  late final SessionRepository _sessionRepository;
  late final List<TextEditingController> _answerControllers;

  PerspectiveScenarioExerciseDto? _exercise;
  bool _isStarting = true;
  bool _isSubmitting = false;
  bool _showValidationErrors = false;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _answerControllers = widget.prompt.questions
        .map((_) => TextEditingController())
        .toList();
    _startScenario();
  }

  @override
  void dispose() {
    for (final controller in _answerControllers) {
      controller.dispose();
    }
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

      setState(() {
        _exercise = startedExercise;
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

      final revealSeen = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PerspectiveScenarioRevealPage(reveal: result.reveal),
        ),
      );

      if (!mounted) return;

      if (revealSeen != false) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isSubmitting = false;
        });
      }
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getLevelColor(widget.prompt.challengeLevel),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.prompt.challengeLevel,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.perspectiveScenarioPromptLabel,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B9B6E),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6B9B6E), width: 1.5),
              ),
              child: Text(
                widget.prompt.scenarioText,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.answerEachScenarioQuestion,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B9B6E),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < widget.prompt.questions.length; i++) ...[
              _buildQuestionCard(i),
              const SizedBox(height: AppSpacing.md + 4),
            ],
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B6E),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
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
                        context.l10n.submit,
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
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = widget.prompt.questions[index];
    final controller = _answerControllers[index];
    final hasError = _showValidationErrors && controller.text.trim().isEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .secondary
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red : Colors.grey[300]!,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.scenarioQuestionNumber(index + 1),
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B9B6E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            maxLines: 4,
            minLines: 4,
            enabled: !_isSubmitting,
            onChanged: (_) {
              if (_showValidationErrors) {
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: context.l10n.shareYourThoughts,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : const Color(0xFF6B9B6E),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              filled: true,
              fillColor: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.12),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            textAlignVertical: TextAlignVertical.top,
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
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
        return Colors.green[600]!;
      case 'medium':
        return Colors.orange[600]!;
      case 'hard':
        return Colors.red[600]!;
      default:
        return const Color(0xFF6B9B6E);
    }
  }
}
