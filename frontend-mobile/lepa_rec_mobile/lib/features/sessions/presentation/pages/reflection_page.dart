import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/dtos/today_practice_task_dto.dart';
import '../../data/dtos/submit_reflection_answer_dto.dart';
import '../../data/repositories/session_repository.dart';

class ReflectionPage extends StatefulWidget {
  final DistancedJournalReflectionPromptDto reflectionPrompt;

  const ReflectionPage({super.key, required this.reflectionPrompt});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

class _ReflectionPageState extends State<ReflectionPage> {
  late final TextEditingController _reflectionController;
  late final SessionRepository _sessionRepository;

  bool _showValidationErrors = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reflectionController = TextEditingController();
    _sessionRepository = SessionRepository();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    return _reflectionController.text.trim().isNotEmpty;
  }

  Future<void> _handleSubmit() async {
    if (widget.reflectionPrompt.exerciseId.trim().isEmpty) {
      _showExerciseNotFound();
      if (mounted) {
        Navigator.pop(context, true);
      }
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
      final submitRequest = SubmitReflectionAnswerDto(
        exerciseId: widget.reflectionPrompt.exerciseId,
        sessionDate: DateTime.now(),
        reflection: _reflectionController.text.trim(),
      );

      await _sessionRepository.submitReflectionAnswer(submitRequest);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.reflectionSubmittedSuccessfully),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 1),
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
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
          content: Text(context.l10n.errorSubmittingReflection(e.toString())),
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
          content: Text(context.l10n.errorSubmittingReflection(e.toString())),
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
          context.l10n.reflectionTitle,
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: Color(0xFF6B9B6E),
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          context.l10n.reflectionPrompt,
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2F3A2F),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                Text(
                  context.l10n.yesterdaysTopic,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3E4A3E),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6B9B6E).withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    widget.reflectionPrompt.challengeContent,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF2F3A2F),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Divider(
                  color: const Color(0xFF6B9B6E).withValues(alpha: 0.2),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  context.l10n.yourPreviousAnswer,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3E4A3E),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6B9B6E).withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    widget.reflectionPrompt.previousMainAnswer ?? '',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF2F3A2F),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Divider(
                  color: const Color(0xFF6B9B6E).withValues(alpha: 0.2),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  context.l10n.previousFollowUpQuestion,
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2F3A2F),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6B9B6E).withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    widget.reflectionPrompt.challengeFollowUpQuestion,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF2F3A2F),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Divider(
                  color: const Color(0xFF6B9B6E).withValues(alpha: 0.2),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  context.l10n.yourPreviousFollowUpAnswer,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3E4A3E),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6B9B6E).withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    widget.reflectionPrompt.previousFollowUpAnswer ?? '',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF2F3A2F),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Divider(
                  color: const Color(0xFF6B9B6E).withValues(alpha: 0.2),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  context.l10n.todayReflection,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3E4A3E),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

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
                  child: _buildTextInputField(
                    controller: _reflectionController,
                    hintText: context.l10n.shareYourThoughts,
                    isError:
                        _showValidationErrors &&
                        _reflectionController.text.trim().isEmpty,
                  ),
                ),

                if (_showValidationErrors &&
                    _reflectionController.text.trim().isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      context.l10n.reflectionRequired,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xxl + AppSpacing.md),

                // Submit button
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
      maxLines: 7,
      minLines: 7,
      enabled: !_isSubmitting,
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

  void _showExerciseNotFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.exerciseNotFoundOrOwned),
        backgroundColor: Colors.red[600],
      ),
    );
  }
}
