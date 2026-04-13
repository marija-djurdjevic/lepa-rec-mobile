import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/dtos/distanced_journal_challenge_dto.dart';
import '../../data/dtos/start_distanced_journal_exercise_dto.dart';
import '../../data/dtos/submit_distanced_journal_answer_dto.dart';
import '../../data/repositories/session_repository.dart';
import 'end_growth_message_page.dart';

class DistancedJournalPage extends StatefulWidget {
  final DistancedJournalChallengeDto challenge;

  const DistancedJournalPage({super.key, required this.challenge});

  @override
  State<DistancedJournalPage> createState() => _DistancedJournalPageState();
}

class _DistancedJournalPageState extends State<DistancedJournalPage> {
  static const double _answerBoxHeight = 360;
  late final TextEditingController _mainAnswerController;
  late final TextEditingController _followUpAnswerController;
  late final SessionRepository _sessionRepository;
  late final ScrollController _scrollController;

  bool _showValidationErrors = false;
  bool _isSubmitting = false;
  bool _showFollowUpQuestion = false;

  @override
  void initState() {
    super.initState();
    _mainAnswerController = TextEditingController();
    _followUpAnswerController = TextEditingController();
    _sessionRepository = SessionRepository();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _mainAnswerController.dispose();
    _followUpAnswerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_mainAnswerController.text.trim().isEmpty ||
        _followUpAnswerController.text.trim().isEmpty) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final startRequest = StartDistancedJournalExerciseDto(
        challengeId: widget.challenge.id,
      );

      final startedExercise = await _sessionRepository
          .startDistancedJournalExercise(startRequest);

      final submitRequest = SubmitDistancedJournalAnswerDto(
        exerciseId: startedExercise.id,
        sessionDate: DateTime.now(),
        mainAnswer: _mainAnswerController.text.trim(),
        followUpAnswer: _followUpAnswerController.text.trim(),
        reflection: null,
      );

      await _sessionRepository.submitDistancedJournalAnswer(
        submitRequest,
      );

      if (!mounted) return;

      final messageCompleted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EndGrowthMessagePage(
                onComplete: () => Navigator.pop(context, true),
              ),
        ),
      );

      if (!mounted) return;

      if (messageCompleted == true) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isSubmitting = false;
        });
      }
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
          content: Text(context.l10n.errorSubmittingResponse(e.toString())),
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
          content: Text(context.l10n.errorSubmittingResponse(e.toString())),
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
          context.l10n.distancedJournal,
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
      body: SafeArea(
        child: SingleChildScrollView(
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
                        widget.challenge.content,
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          height: 1.4,
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
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelColor(
                            widget.challenge.challengeLevel,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getLevelLabel(
                            widget.challenge.challengeLevel,
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
                const SizedBox(height: AppSpacing.xl + AppSpacing.xs),
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
                    child: _buildTextInputField(
                      controller: _mainAnswerController,
                      hintText: context.l10n.shareYourThoughts,
                      isError:
                          _showValidationErrors &&
                          _mainAnswerController.text.trim().isEmpty,
                      expands: true,
                    ),
                  ),
                ),
                if (_showValidationErrors &&
                    _mainAnswerController.text.trim().isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      context.l10n.answerRequired,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                if (!_showFollowUpQuestion &&
                    _mainAnswerController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B9B6E),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        context.l10n.wrapUp,
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_showFollowUpQuestion) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    widget.challenge.followUpQuestion,
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                      child: _buildTextInputField(
                        controller: _followUpAnswerController,
                        hintText: context.l10n.shareYourThoughts,
                        isError:
                            _showValidationErrors &&
                            _followUpAnswerController.text.trim().isEmpty,
                        expands: true,
                      ),
                    ),
                  ),
                  if (_showValidationErrors &&
                      _followUpAnswerController.text.trim().isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        context.l10n.answerRequired,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
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
                        elevation: 2,
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
        ),
      ),
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

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String hintText,
    required bool isError,
    bool expands = false,
    int minLines = 10,
    int maxLines = 10,
  }) {
    return TextField(
      controller: controller,
      maxLines: expands ? null : maxLines,
      minLines: expands ? null : minLines,
      expands: expands,
      enabled: !_isSubmitting,
      onChanged: (_) {
        if (_showValidationErrors) {
          setState(() {});
        }
        if (controller == _mainAnswerController) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.grey[300]!,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.grey[300]!,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xFF6B9B6E),
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
      case 'teško':
        return context.l10n.levelHard;
      default:
        return level;
    }
  }

  Future<void> _handleContinue() async {
    if (_mainAnswerController.text.trim().isEmpty) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      _showFollowUpQuestion = true;
    });

    _scrollToBottom();
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
}
