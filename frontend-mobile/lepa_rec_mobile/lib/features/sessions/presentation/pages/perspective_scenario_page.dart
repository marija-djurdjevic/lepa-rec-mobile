import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/dtos/answer_perspective_scenario_question_dto.dart';
import '../../data/dtos/perspective_scenario_answer_dto.dart';
import '../../data/dtos/perspective_scenario_exercise_dto.dart';
import '../../data/dtos/perspective_scenario_prompt_dto.dart';
import '../../data/dtos/perspective_scenario_question_dto.dart';
import '../../data/dtos/start_perspective_scenario_dto.dart';
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
  late final List<PerspectiveScenarioQuestionDto> _orderedQuestions;
  late final List<TextEditingController> _answerControllers;
  late final ScrollController _scrollController;

  PerspectiveScenarioExerciseDto? _exercise;
  int _visibleQuestionCount = 0;
  bool _isStarting = true;
  bool _isSubmitting = false;
  bool _showValidationErrors = false;
  bool _isFlowSubmitted = false;
  String? _loadingError;
  String? _activePracticeLang;
  final Map<String, String> _answersByQuestionId = {};
  final Map<String, String> _revealsByQuestionId = {};
  final Map<int, String> _revealsByOrder = {};

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _orderedQuestions = [...widget.prompt.questions]
      ..sort((a, b) => a.order.compareTo(b.order));
    _answerControllers = _orderedQuestions
        .map((_) => TextEditingController())
        .toList();
    _scrollController = ScrollController();
    _visibleQuestionCount = _orderedQuestions.isEmpty ? 0 : 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang =
        Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr';
    if (_activePracticeLang == currentLang) return;
    _activePracticeLang = currentLang;
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
      _isFlowSubmitted = false;
      _answersByQuestionId.clear();
      _revealsByQuestionId.clear();
      _revealsByOrder.clear();
    });

    try {
      final startedExercise = await _sessionRepository.startPerspectiveScenario(
        StartPerspectiveScenarioDto(challengeId: widget.prompt.id),
        _activePracticeLang ?? 'sr',
      );

      if (!mounted) return;

      if (kDebugMode) {
        final questionDebug = _orderedQuestions
            .map(
              (q) =>
                  '#${q.order}(id=${q.id}, hasReveal=${(q.reveal ?? '').trim().isNotEmpty})',
            )
            .join(', ');
        debugPrint(
          '[PerspectiveScenario][UI] start '
          'lang=${_activePracticeLang ?? 'sr'} '
          'challengeId=${widget.prompt.id} '
          'questions=${_orderedQuestions.length} [$questionDebug]',
        );
      }

      for (var i = 0; i < _orderedQuestions.length; i++) {
        final questionId = _orderedQuestions[i].id;
        PerspectiveScenarioAnswerDto? existingAnswer;
        for (final answer in startedExercise.answers) {
          if (answer.questionId == questionId) {
            existingAnswer = answer;
            break;
          }
        }
        final answerText = existingAnswer?.answerText ?? '';
        _answerControllers[i].text = answerText;
        if (answerText.trim().isNotEmpty) {
          _answersByQuestionId[questionId] = answerText.trim();
        }
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

  Future<void> _answerCurrentQuestionAndReveal(int index) async {
    if (_exercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.exerciseNotInitialized),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    final question = _orderedQuestions[index];
    final answerText = _answerControllers[index].text.trim();
    if (answerText.isEmpty) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _sessionRepository.answerPerspectiveScenarioAndReveal(
        AnswerPerspectiveScenarioQuestionDto(
          exerciseId: _exercise!.id,
          questionId: question.id,
          answerText: answerText,
        ),
        _activePracticeLang ?? 'sr',
      );

      if (!mounted) return;

      _exercise = response.exercise;
      for (final answer in response.exercise.answers) {
        if (answer.answerText.trim().isNotEmpty) {
          _answersByQuestionId[answer.questionId] = answer.answerText.trim();
        }
      }
      for (var i = 0; i < _orderedQuestions.length; i++) {
        final questionId = _orderedQuestions[i].id;
        final saved = _answersByQuestionId[questionId];
        if (saved != null && saved.isNotEmpty) {
          _answerControllers[i].text = saved;
        }
      }

      final revealText = response.reveal?.reveal.trim();
      final revealQuestionId = response.reveal?.questionId;
      final revealOrder = response.reveal?.order;

      if (response.isExerciseCompleted) {
        try {
          await _sessionRepository.recordExercise(
            exerciseId: response.exercise.id,
            type: 'PerspectiveScenario',
          );
        } catch (e) {
          debugPrint('[PerspectiveScenario] recordExercise failed: $e');
        }
      }

      setState(() {
        if (revealText != null &&
            revealText.isNotEmpty &&
            revealQuestionId != null &&
            revealQuestionId.isNotEmpty) {
          _revealsByQuestionId[revealQuestionId] = revealText;
        }
        if (revealText != null &&
            revealText.isNotEmpty &&
            revealOrder != null &&
            revealOrder > 0) {
          _revealsByOrder[revealOrder] = revealText;
        }
        _isFlowSubmitted = response.isExerciseCompleted;
        _isSubmitting = false;
      });

      if ((revealText == null || revealText.isEmpty) && kDebugMode) {
        debugPrint(
          '[PerspectiveScenario][UI] answer_and_reveal returned empty reveal '
          'questionId=${question.id}',
        );
      }

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

  Future<void> _finishScenario() async {
    final developedSkillIds = _collectDevelopedSkillIds();
    final messageCompleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EndGrowthMessagePage(
          onComplete: () => Navigator.pop(context, true),
          developedSkillIds: developedSkillIds,
        ),
      ),
    );

    if (!mounted) return;

    if (messageCompleted == true) {
      Navigator.pop(context, true);
    }
  }

  List<String> _collectDevelopedSkillIds() {
    final answeredQuestionIds = _answersByQuestionId.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map((entry) => entry.key)
        .toSet();
    final developedSkillIds = <String>{};

    for (final question in _orderedQuestions) {
      if (!answeredQuestionIds.contains(question.id)) continue;
      final skillId = question.skillId.trim();
      if (skillId.isEmpty) continue;
      developedSkillIds.add(skillId);
    }

    return developedSkillIds.toList();
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
                      child: _isSubmitting
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
                              _isFlowSubmitted && _isLastQuestion(i)
                                  ? context.l10n.conclude
                                  : _hasRevealForQuestion(_orderedQuestions[i])
                                  ? context.l10n.continueToNext
                                  : _isLastQuestion(i)
                                  ? context.l10n.wrapUp
                                  : context.l10n.continueToNext,
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
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _orderedQuestions[index];
    final controller = _answerControllers[index];
    final hasError = _showValidationErrors && controller.text.trim().isEmpty;
    final isReadOnly =
        _isFlowSubmitted || _revealsByQuestionId.containsKey(question.id);
    final revealText = _findRevealForQuestion(question);

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
        if (revealText != null && revealText.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildRevealCard(revealText),
        ],
      ],
    );
  }

  int _calculateVisibleQuestionCount() {
    if (_orderedQuestions.isEmpty) {
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
    return index == _orderedQuestions.length - 1;
  }

  bool _shouldShowContinueButton(int index) {
    if (index != _visibleQuestionCount - 1) {
      return false;
    }

    if (_isFlowSubmitted && _isLastQuestion(index)) {
      return true;
    }

    return _hasText(index) || _hasRevealForQuestion(_orderedQuestions[index]);
  }

  void _handleContinue(int index) async {
    final question = _orderedQuestions[index];
    final hasReveal = _hasRevealForQuestion(question);

    if (_isFlowSubmitted && _isLastQuestion(index)) {
      await _finishScenario();
      return;
    }

    if (hasReveal) {
      if (_isLastQuestion(index)) {
        await _finishScenario();
        return;
      }
      if (_visibleQuestionCount < _orderedQuestions.length) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        setState(() {
          _visibleQuestionCount += 1;
        });
        _scrollToBottom();
      }
      return;
    }

    if (!_hasText(index)) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[PerspectiveScenario][UI] continue '
        'index=$index '
        'questionId=${question.id} '
        'answerLen=${_answerControllers[index].text.trim().length} '
        'hasReveal=$hasReveal',
      );
    }
    await _answerCurrentQuestionAndReveal(index);
  }

  bool _hasRevealForQuestion(PerspectiveScenarioQuestionDto question) {
    final reveal = _findRevealForQuestion(question);
    return reveal != null && reveal.trim().isNotEmpty;
  }

  String? _findRevealForQuestion(PerspectiveScenarioQuestionDto question) {
    final byQuestionId = _revealsByQuestionId[question.id];
    if (byQuestionId != null && byQuestionId.trim().isNotEmpty) {
      return byQuestionId;
    }
    return _revealsByOrder[question.order];
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
