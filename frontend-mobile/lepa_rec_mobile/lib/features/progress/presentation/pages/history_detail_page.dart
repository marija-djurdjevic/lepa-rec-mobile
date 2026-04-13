import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../data/models/history_item.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9F3),
        elevation: 0,
        title: Text(
          _titleForItem(context),
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
                _buildPromptSection(context),
                const SizedBox(height: AppSpacing.lg),
                _buildAnswerSection(context),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _titleForItem(BuildContext context) {
    switch (item.type) {
      case HistoryItemType.distancedJournal:
        return context.l10n.distancedJournal;
      case HistoryItemType.perspectiveScenario:
        return context.l10n.perspectiveScenario;
    }
  }

  Widget _buildPromptSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F0).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B9B6E).withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.safePromptText,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          if (item.followUpPrompt != null &&
              item.followUpPrompt!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.followUpPrompt!,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
          if (item.questions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final question in item.questions) ...[
              Text(
                question.text.trim().isEmpty ? 'Question' : question.text,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F0).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B9B6E).withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.type == HistoryItemType.distancedJournal) ...[
            _buildAnswerText(item.mainAnswer),
            if (item.followUpAnswer != null &&
                item.followUpAnswer!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildAnswerText(item.followUpAnswer),
            ],
            if (item.reflection != null &&
                item.reflection!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.reflectionAfterTimeLabel,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B9B6E),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _buildAnswerText(item.reflection),
            ],
          ] else ...[
            if (item.answers.isEmpty)
              _buildAnswerText('Answer unavailable'),
            for (final answer in item.answers) ...[
              _buildAnswerText(answer.answerText),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerText(String? value) {
    final text = value == null || value.trim().isEmpty
        ? 'Answer unavailable'
        : value.trim();
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
        height: 1.4,
      ),
    );
  }
}
