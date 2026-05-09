import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _mainPhotos = [];
  final List<XFile> _followUpPhotos = [];

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

  bool get _hasTextInput =>
      _mainAnswerController.text.trim().isNotEmpty ||
      _followUpAnswerController.text.trim().isNotEmpty;

  bool get _isTextComplete =>
      _mainAnswerController.text.trim().isNotEmpty &&
      _followUpAnswerController.text.trim().isNotEmpty;

  bool get _hasPhotos => _mainPhotos.isNotEmpty || _followUpPhotos.isNotEmpty;

  int get _totalPhotoCount => _mainPhotos.length + _followUpPhotos.length;

  bool get _hasAnyResponse => _hasTextInput || _hasPhotos;

  Future<void> _pickPhotos(_PhotoAnchor anchor) async {
    if (_totalPhotoCount >= 3) {
      _showPhotoLimitMessage();
      return;
    }

    final picked = await _imagePicker.pickMultiImage();
    if (picked.isEmpty) return;

    setState(() {
      final target = _photosFor(anchor);
      for (final photo in picked) {
        if (_totalPhotoCount >= 3) break;
        target.add(photo);
      }
    });

    if (_totalPhotoCount == 3 && picked.length > 0) {
      _showPhotoLimitMessage();
    }
  }

  Future<void> _pickPhotoFromCamera(_PhotoAnchor anchor) async {
    if (_totalPhotoCount >= 3) {
      _showPhotoLimitMessage();
      return;
    }

    final picked = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() {
      _photosFor(anchor).add(picked);
    });
  }

  Future<void> _showPhotoSourcePicker(_PhotoAnchor anchor) async {
    if (_isSubmitting) return;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(
                    'Take photo',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickPhotoFromCamera(anchor);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(
                    'Choose from library',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickPhotos(anchor);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removePhotoAt(List<XFile> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    debugPrint('[DistancedJournal] Submit tapped');
    final hasPhotos = _hasPhotos;
    final hasText = _hasTextInput;
    final isTextComplete = _isTextComplete;

    if (!hasText && !hasPhotos) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }

    if (hasText && !isTextComplete) {
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

      debugPrint('[DistancedJournal] Starting exercise');
      final startedExercise = await _sessionRepository
          .startDistancedJournalExercise(
            startRequest,
            _currentPracticeLang(),
          );
      debugPrint(
        '[DistancedJournal] Started exercise id=${startedExercise.id}',
      );

      debugPrint(
        '[DistancedJournal] Submitting answer with photos=$hasPhotos '
        'textComplete=$isTextComplete',
      );
      final submitResult = hasPhotos
          ? await _sessionRepository.submitDistancedJournalAnswerWithPhotos(
              exerciseId: startedExercise.id,
              sessionDate: DateTime.now(),
              mainAnswer: isTextComplete
                  ? _mainAnswerController.text.trim()
                  : null,
              followUpAnswer: isTextComplete
                  ? _followUpAnswerController.text.trim()
                  : null,
              reflection: null,
              photoPaths: [
                ..._mainPhotos.map((photo) => photo.path),
                ..._followUpPhotos.map((photo) => photo.path),
              ],
              lang: _currentPracticeLang(),
            )
          : await _sessionRepository.submitDistancedJournalAnswer(
              SubmitDistancedJournalAnswerDto(
                exerciseId: startedExercise.id,
                sessionDate: DateTime.now(),
                mainAnswer: _mainAnswerController.text.trim(),
                followUpAnswer: _followUpAnswerController.text.trim(),
                reflection: null,
              ),
              _currentPracticeLang(),
            );
      debugPrint(
        '[DistancedJournal] Submit completed feedbackType='
        '${submitResult.feedbackType ?? 'null'}',
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
                const SizedBox(height: AppSpacing.lg + AppSpacing.xs),
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
                          _hasTextInput &&
                          _mainAnswerController.text.trim().isEmpty,
                      showPhotoPicker: true,
                      photoThumbnails: _mainPhotos,
                      expands: true,
                    ),
                  ),
                ),
                if (_showValidationErrors && !_hasAnyResponse)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: const Text(
                      'Add both text answers or at least one photo.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                if (_showValidationErrors &&
                    _hasTextInput &&
                    _mainAnswerController.text.trim().isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      context.l10n.answerRequired,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                if (!_showFollowUpQuestion &&
                    (_mainAnswerController.text.trim().isNotEmpty ||
                        _hasPhotos)) ...[
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
                            _hasTextInput &&
                            _followUpAnswerController.text.trim().isEmpty,
                        showPhotoPicker: true,
                        photoThumbnails: _followUpPhotos,
                        expands: true,
                      ),
                    ),
                  ),
                  if (_showValidationErrors &&
                      _hasTextInput &&
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

  void _showPhotoLimitMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.photoLimitMessage),
        backgroundColor: Colors.orange[600],
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String hintText,
    required bool isError,
    bool showPhotoPicker = false,
    List<XFile> photoThumbnails = const [],
    bool expands = false,
    int minLines = 10,
    int maxLines = 10,
  }) {
    final bool showThumbnails = photoThumbnails.isNotEmpty;
    const double thumbnailSize = 80;
    final double thumbnailPadding = showThumbnails
        ? (thumbnailSize + AppSpacing.sm)
        : 0;
    const double iconSize = 32;
    final double iconInset = showPhotoPicker ? (iconSize + AppSpacing.sm) : 0;

    final field = TextField(
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
        contentPadding: EdgeInsets.fromLTRB(
          AppSpacing.lg + iconInset,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + thumbnailPadding,
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

    if (!showThumbnails && !showPhotoPicker) {
      return field;
    }

    return Stack(
      children: [
        field,
        if (showPhotoPicker)
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
                child: IconButton(
                  onPressed: _isSubmitting || _totalPhotoCount >= 3
                      ? null
                      : () => _showPhotoSourcePicker(_photoAnchorFor(controller)),
                  icon: const Icon(Icons.add_a_photo_outlined),
                  color: const Color(0xFF6B9B6E),
                  tooltip: 'Add photo',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
        if (showThumbnails)
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.sm,
            child: _buildPhotoThumbnails(thumbnailSize, photoThumbnails),
          ),
      ],
    );
  }

  _PhotoAnchor _photoAnchorFor(TextEditingController controller) {
    if (controller == _followUpAnswerController) {
      return _PhotoAnchor.followUp;
    }
    return _PhotoAnchor.main;
  }

  List<XFile> _photosFor(_PhotoAnchor anchor) {
    return anchor == _PhotoAnchor.followUp ? _followUpPhotos : _mainPhotos;
  }

  Widget _buildPhotoThumbnails(double size, List<XFile> photos) {
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (int i = 0; i < photos.length; i++)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Image.file(
                    File(photos[i].path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: InkWell(
                  onTap: _isSubmitting ? null : () => _removePhotoAt(photos, i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
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
    if (_mainAnswerController.text.trim().isEmpty && !_hasPhotos) {
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

  String _currentPracticeLang() {
    return Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr';
  }
}

enum _PhotoAnchor { main, followUp }
