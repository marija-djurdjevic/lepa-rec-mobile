import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/config/api_environment.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
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
              children: item.type == HistoryItemType.perspectiveScenario
                  ? [
                      _buildPerspectiveHistory(context),
                      const SizedBox(height: AppSpacing.lg),
                    ]
                  : [
                      _buildDistancedJournalHistory(context),
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

  Widget _buildDistancedJournalHistory(BuildContext context) {
    final promptParts = _distancedJournalPromptParts();
    final followUpPrompt = item.followUpPrompt?.trim();
    final mainAnswer = item.mainAnswer?.trim();
    final followUpAnswer = item.followUpAnswer?.trim();
    final reflection = item.reflection?.trim();
    final generatedReflectionQuestion = item.generatedReflectionQuestion
        ?.trim();
    final generatedReflectionAnswer = item.generatedReflectionAnswer?.trim();
    final hasPhotos = item.photoUrls.isNotEmpty;
    final hasMainText = mainAnswer != null && mainAnswer.isNotEmpty;
    final hasFollowUpText = followUpAnswer != null && followUpAnswer.isNotEmpty;
    final hasAnyTextAnswer = hasMainText || hasFollowUpText;
    final hasGeneratedReflection =
        generatedReflectionAnswer != null &&
        generatedReflectionAnswer.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPromptCard(context, text: promptParts.contextText),
        const SizedBox(height: AppSpacing.lg),
        if (!hasAnyTextAnswer && hasPhotos) ...[
          _buildPhotoQuestionsCard(
            context,
            openingQuestion: promptParts.questionText,
            followUpQuestion: followUpPrompt,
          ),
          const SizedBox(height: AppSpacing.md),
        ] else if (promptParts.questionText.isNotEmpty || hasMainText) ...[
          _buildQuestionAnswerRevealCard(
            context,
            questionText: promptParts.questionText,
            answerText: hasMainText ? mainAnswer : _answerUnavailable(context),
            revealText: null,
            showQuestion: promptParts.questionText.isNotEmpty,
            useResponsePanels: false,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (followUpPrompt != null &&
            followUpPrompt.isNotEmpty &&
            hasAnyTextAnswer) ...[
          _buildQuestionAnswerRevealCard(
            context,
            questionText: followUpPrompt,
            answerText: hasFollowUpText
                ? followUpAnswer
                : _answerUnavailable(context),
            revealText: null,
            useResponsePanels: false,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (reflection != null && reflection.isNotEmpty) ...[
          _buildQuestionAnswerRevealCard(
            context,
            questionText: (item.reflectionQuestion?.trim().isNotEmpty ?? false)
                ? item.reflectionQuestion!.trim()
                : context.l10n.reflectionFreshQuestion,
            answerText: reflection,
            revealText: null,
            useResponsePanels: false,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (hasGeneratedReflection) ...[
          _buildQuestionAnswerRevealCard(
            context,
            questionText:
                generatedReflectionQuestion != null &&
                    generatedReflectionQuestion.isNotEmpty
                ? generatedReflectionQuestion
                : context.l10n.generatedReflectionQuestionTitle,
            answerText: generatedReflectionAnswer,
            revealText: null,
            useResponsePanels: false,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (item.photoUrls.isNotEmpty) _buildPhotoCard(item.photoUrls),
      ],
    );
  }

  Widget _buildPhotoQuestionsCard(
    BuildContext context, {
    required String openingQuestion,
    required String? followUpQuestion,
  }) {
    final trimmedOpening = openingQuestion.trim();
    final trimmedFollowUp = followUpQuestion?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8D8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trimmedOpening.isNotEmpty) ...[
            _buildQuestionHeader(context, trimmedOpening, useAnswerColor: true),
          ],
          if (trimmedOpening.isNotEmpty && trimmedFollowUp.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          if (trimmedFollowUp.isNotEmpty) ...[
            _buildQuestionHeader(
              context,
              trimmedFollowUp,
              useAnswerColor: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerspectiveHistory(BuildContext context) {
    final answerByQuestionId = {
      for (final answer in item.answers) answer.questionId: answer,
    };
    final orderedAnswers = <HistoryAnswer>[
      for (final question in item.questions)
        if (answerByQuestionId[question.id] != null)
          answerByQuestionId[question.id]!,
      for (final answer in item.answers)
        if (!item.questions.any((question) => question.id == answer.questionId))
          answer,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPromptCard(context, text: item.safePromptText),
        const SizedBox(height: AppSpacing.lg),
        if (orderedAnswers.isEmpty)
          _buildQuestionAnswerRevealCard(
            context,
            questionText: _questionUnavailable(context),
            answerText: _answerUnavailable(context),
            revealText: null,
            useQuestionAnswerTextOnly: true,
          )
        else
          for (final entry in orderedAnswers.asMap().entries) ...[
            _buildQuestionAnswerRevealCard(
              context,
              questionText: entry.value.questionText,
              answerText: entry.value.answerText,
              revealText: entry.value.revealText,
              useQuestionAnswerTextOnly: true,
            ),
            if (entry.key != orderedAnswers.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Widget _buildPromptCard(BuildContext context, {required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2E3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF6B9B6E).withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.trim().isEmpty ? item.safePromptText : text.trim(),
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3E5A42),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnswerRevealCard(
    BuildContext context, {
    required String questionText,
    required String answerText,
    required String? revealText,
    bool showQuestion = true,
    bool useResponsePanels = true,
    bool useQuestionAnswerTextOnly = false,
  }) {
    final reveal = revealText?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8D8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showQuestion) ...[
            _buildQuestionHeader(
              context,
              questionText,
              useAnswerColor: !useResponsePanels || useQuestionAnswerTextOnly,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (useQuestionAnswerTextOnly)
            _buildHistoryText(
              answerText.trim().isEmpty
                  ? _answerUnavailable(context)
                  : answerText.trim(),
            )
          else if (useResponsePanels)
            _buildResponsePanel(
              text: answerText.trim().isEmpty
                  ? _answerUnavailable(context)
                  : answerText.trim(),
              color: const Color(0xFFF5F7F3),
              borderColor: const Color(0xFFE0E7DE),
            )
          else
            _buildHistoryText(
              answerText.trim().isEmpty
                  ? _answerUnavailable(context)
                  : answerText.trim(),
            ),
          if (reveal != null && reveal.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            if (useResponsePanels)
              _buildResponsePanel(
                text: reveal,
                color: const Color(0xFFEAF5E7),
                borderColor: const Color(0xFFBBD8B9),
              )
            else
              _buildHistoryText(reveal),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(
    BuildContext context,
    String questionText, {
    bool useAnswerColor = false,
  }) {
    return Text(
      questionText.trim().isEmpty
          ? _questionUnavailable(context)
          : questionText.trim(),
      style: GoogleFonts.quicksand(
        fontSize: 15,
        fontWeight: useAnswerColor ? FontWeight.w500 : FontWeight.w400,
        color: useAnswerColor
            ? const Color(0xFF485348)
            : const Color(0xFF7F8D7E),
        height: 1.35,
      ),
    );
  }

  Widget _buildHistoryText(String text) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF485348),
        height: 1.45,
      ),
    );
  }

  _DistancedJournalPromptParts _distancedJournalPromptParts() {
    final text = item.safePromptText;
    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (paragraphs.length > 1) {
      final question = paragraphs.last;
      final contextText = paragraphs.take(paragraphs.length - 1).join('\n\n');
      return _DistancedJournalPromptParts(
        contextText: contextText,
        questionText: question,
      );
    }

    final questionStart = text.lastIndexOf('?');
    if (questionStart > 0 && questionStart < text.length - 1) {
      return _DistancedJournalPromptParts(
        contextText: text.substring(0, questionStart + 1).trim(),
        questionText: text.substring(questionStart + 1).trim(),
      );
    }

    return _DistancedJournalPromptParts(contextText: text, questionText: '');
  }

  Widget _buildPhotoCard(List<String> urls) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8D8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildPhotoGallery(urls),
    );
  }

  Widget _buildResponsePanel({
    required String text,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.quicksand(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF485348),
          height: 1.45,
        ),
      ),
    );
  }

  bool _isEnglish(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'en';
  }

  String _answerUnavailable(BuildContext context) {
    return _isEnglish(context) ? 'Answer unavailable' : 'Odgovor nije dostupan';
  }

  String _questionUnavailable(BuildContext context) {
    return _isEnglish(context)
        ? 'Question unavailable'
        : 'Pitanje nije dostupno';
  }

  Widget _buildPhotoGallery(List<String> urls) {
    return FutureBuilder<String?>(
      future: AuthLocalDataSource().readAccessToken(),
      builder: (context, snapshot) {
        final token = snapshot.data;
        final headers = token != null && token.isNotEmpty
            ? <String, String>{'Authorization': 'Bearer $token'}
            : null;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final entry in urls.asMap().entries)
              GestureDetector(
                onTap: () =>
                    _openPhotoViewer(context, urls, entry.key, headers),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: Image.network(
                      _resolvePhotoUrl(entry.value),
                      fit: BoxFit.cover,
                      headers: headers,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8ECE6),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 20,
                            color: Color(0xFF9AA79A),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _resolvePhotoUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final base = Uri.parse(ApiEnvironment.baseUrl);
    final origin =
        '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }
    return '$origin/$trimmed';
  }

  void _openPhotoViewer(
    BuildContext context,
    List<String> urls,
    int initialIndex,
    Map<String, String>? headers,
  ) {
    final resolvedUrls = urls.map(_resolvePhotoUrl).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PhotoViewerPage(
          urls: resolvedUrls,
          initialIndex: initialIndex,
          headers: headers,
        ),
      ),
    );
  }
}

class _DistancedJournalPromptParts {
  final String contextText;
  final String questionText;

  const _DistancedJournalPromptParts({
    required this.contextText,
    required this.questionText,
  });
}

class _PhotoViewerPage extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final Map<String, String>? headers;

  const _PhotoViewerPage({
    required this.urls,
    required this.initialIndex,
    required this.headers,
  });

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  late final PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.urls.length) return;
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrev = _currentIndex > 0;
    final canGoNext = _currentIndex < widget.urls.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.urls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final url = widget.urls[index].trim();
                return Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.network(
                      url,
                      headers: widget.headers,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1C1C1C),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 32,
                            color: Color(0xFF9AA79A),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (widget.urls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(
                  '${_currentIndex + 1} / ${widget.urls.length}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
            if (canGoPrev)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white70),
                    onPressed: () => _goTo(_currentIndex - 1),
                  ),
                ),
              ),
            if (canGoNext)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                    ),
                    onPressed: () => _goTo(_currentIndex + 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
