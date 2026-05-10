import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
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
    return SizedBox(
      width: double.infinity,
      child: Container(
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
      ),
    );
  }

  Widget _buildAnswerSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
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
              if (item.mainAnswer != null &&
                  item.mainAnswer!.trim().isNotEmpty)
                _buildAnswerText(item.mainAnswer)
              else if (item.photoUrls.isEmpty)
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
              if (item.photoUrls.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _buildPhotoGallery(item.photoUrls),
              ],
            ] else ...[
              if (item.answers.isEmpty)
                _buildAnswerText('Answer unavailable'),
              for (final answer in item.answers) ...[
                _buildAnswerText(answer.answerText),
                if (answer.revealText != null &&
                    answer.revealText!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F2E3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      answer.revealText!.trim(),
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF557157),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ],
        ),
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
                onTap: () => _openPhotoViewer(
                  context,
                  urls,
                  entry.key,
                  headers,
                ),
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

    final base = Uri.parse(AppConstants.apiBaseUrl);
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
                    icon:
                        const Icon(Icons.chevron_right, color: Colors.white70),
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
