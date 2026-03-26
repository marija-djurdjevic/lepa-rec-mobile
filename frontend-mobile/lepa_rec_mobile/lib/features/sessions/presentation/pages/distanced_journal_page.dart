import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../data/dtos/distanced_journal_challenge_dto.dart';
import '../../data/dtos/start_distanced_journal_exercise_dto.dart';
import '../../data/dtos/submit_distanced_journal_answer_dto.dart';
import '../../data/repositories/session_repository.dart';
import 'journal_feedback_page.dart';

class DistancedJournalPage extends StatefulWidget {
  final DistancedJournalChallengeDto challenge;

  const DistancedJournalPage({super.key, required this.challenge});

  @override
  State<DistancedJournalPage> createState() => _DistancedJournalPageState();
}

class _DistancedJournalPageState extends State<DistancedJournalPage> {
  late final TextEditingController _mainAnswerController;
  late final TextEditingController _followUpAnswerController;
  late final SessionRepository _sessionRepository;

  bool _showValidationErrors = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _mainAnswerController = TextEditingController();
    _followUpAnswerController = TextEditingController();
    _sessionRepository = SessionRepository();
  }

  @override
  void dispose() {
    _mainAnswerController.dispose();
    _followUpAnswerController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    return _mainAnswerController.text.trim().isNotEmpty &&
        _followUpAnswerController.text.trim().isNotEmpty;
  }

  Future<void> _handleSubmit() async {
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

      final result = await _sessionRepository.submitDistancedJournalAnswer(
        submitRequest,
      );

      if (!mounted) return;

      final feedbackCompleted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              JournalFeedbackPage(feedbackType: result.feedbackType),
        ),
      );

      if (!mounted) return;

      if (feedbackCompleted == true) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLevelColor(widget.challenge.challengeLevel),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.challenge.challengeLevel,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  widget.challenge.content,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B9B6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  context.l10n.yourAnswer,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B9B6E),
                  ),
                ),
                const SizedBox(height: 8),

                _buildTextInputField(
                  controller: _mainAnswerController,
                  hintText: context.l10n.shareYourThoughts,
                  isError:
                      _showValidationErrors &&
                      _mainAnswerController.text.trim().isEmpty,
                ),

                if (_showValidationErrors &&
                    _mainAnswerController.text.trim().isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      context.l10n.answerRequired,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 32),

                Text(
                  widget.challenge.followUpQuestion,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B9B6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  context.l10n.followUpAnswer,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B9B6E),
                  ),
                ),
                const SizedBox(height: 8),

                _buildTextInputField(
                  controller: _followUpAnswerController,
                  hintText: context.l10n.shareYourThoughts,
                  isError:
                      _showValidationErrors &&
                      _followUpAnswerController.text.trim().isEmpty,
                ),

                if (_showValidationErrors &&
                    _followUpAnswerController.text.trim().isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      context.l10n.answerRequired,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 48),

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
                            context.l10n.submit,
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String hintText,
    required bool isError,
  }) {
    return TextField(
      controller: controller,
      maxLines: 5,
      minLines: 5,
      enabled: !_isSubmitting,
      onChanged: (_) {
        if (_showValidationErrors) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xFF6B9B6E),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
      ),
      style: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      textAlignVertical: TextAlignVertical.top,
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
