import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/dtos/today_practice_task_dto.dart';
import '../../data/dtos/submit_reflection_answer_dto.dart';
import '../../data/repositories/session_repository.dart';
import 'end_growth_message_page.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

class ReflectionPage extends StatefulWidget {
  final DistancedJournalReflectionPromptDto reflectionPrompt;

  const ReflectionPage({super.key, required this.reflectionPrompt});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

class _ReflectionPageState extends State<ReflectionPage> {
  static const double _reflectionBoxHeight = 380;

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
      if (!mounted) return;

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
      } else {
        setState(() => _isSubmitting = false);
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

      await _sessionRepository.submitReflectionAnswer(
        submitRequest,
        _currentPracticeLang(),
      );

      if (!mounted) return;

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
      } else {
        setState(() => _isSubmitting = false);
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
                Text(
                  context.l10n.reflectionGuidance,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B9B6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                SizedBox(
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
                          widget.reflectionPrompt.challengeContent,
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.reflectionPrompt.challengeFollowUpQuestion,
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
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
                          widget.reflectionPrompt.previousMainAnswer ?? '',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.reflectionPrompt.previousFollowUpAnswer ?? '',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        if (widget.reflectionPrompt.previousPhotoUrls.isNotEmpty)
                          ...[
                            const SizedBox(height: AppSpacing.md),
                            _buildPhotoGallery(
                              widget.reflectionPrompt.previousPhotoUrls,
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

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
                  child: Text(
                    context.l10n.reflectionFreshQuestion,
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: _reflectionBoxHeight,
                    child: _buildTextInputField(
                      controller: _reflectionController,
                      hintText: context.l10n.shareYourThoughts,
                      isError:
                          _showValidationErrors &&
                          _reflectionController.text.trim().isEmpty,
                      expands: true,
                    ),
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
    bool expands = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: expands ? null : 7,
      minLines: expands ? null : 7,
      expands: expands,
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
    if (trimmed.isEmpty) return trimmed;
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

  String _currentPracticeLang() {
    return Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr';
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
