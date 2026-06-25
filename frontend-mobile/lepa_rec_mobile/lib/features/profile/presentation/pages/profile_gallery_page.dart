import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../rewards/data/repositories/reward_repository.dart';
import '../../../sessions/data/dtos/reward_progress_dto.dart';

class ProfileGalleryPage extends StatefulWidget {
  const ProfileGalleryPage({super.key});

  @override
  State<ProfileGalleryPage> createState() => _ProfileGalleryPageState();
}

class _ProfileGalleryPageState extends State<ProfileGalleryPage> {
  static const Color _primary = Color(0xFF6B9B6E);
  static const Color _textMuted = Color(0xFF6A776F);
  static const Color _surfaceSoft = Color(0xFFF7FBF5);
  static const Color _border = Color(0xFFD9E5D7);

  late final RewardRepository _rewardRepository;
  late Future<List<RewardProgressDto>> _galleryFuture;

  @override
  void initState() {
    super.initState();
    _rewardRepository = RewardRepository();
    _galleryFuture = _rewardRepository.getGallery();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppTopBar(title: isEnglish ? 'Gallery' : 'Galerija'),
      body: SafeArea(
        child: FutureBuilder<List<RewardProgressDto>>(
          future: _galleryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildMessageState(
                icon: Icons.error_outline_rounded,
                text: isEnglish
                    ? 'Could not load gallery.'
                    : 'Nismo uspjeli učitati galeriju.',
              );
            }

            final rewards = snapshot.data ?? const [];
            if (rewards.isEmpty) {
              return _buildMessageState(
                icon: Icons.collections_bookmark_outlined,
                text: isEnglish
                    ? 'Saved pictures will appear here.'
                    : 'Sačuvane slike će se pojaviti ovdje.',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: rewards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final reward = rewards[index];
                return _GalleryTile(
                  reward: reward,
                  dateLabel: _formatGalleryDate(
                    reward.savedAt ?? reward.completedAt,
                  ),
                  onTap: () => _openGalleryReward(reward),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageState({required IconData icon, required String text}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _primary, size: 36),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                color: _textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGalleryDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day.$month.${local.year}.';
  }

  void _openGalleryReward(RewardProgressDto reward) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 3,
                  child: _RewardImage(reward: reward, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final RewardProgressDto reward;
  final String dateLabel;
  final VoidCallback onTap;

  const _GalleryTile({
    required this.reward,
    required this.dateLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _ProfileGalleryPageState._surfaceSoft,
            border: Border.all(color: _ProfileGalleryPageState._border),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _RewardImage(reward: reward, fit: BoxFit.cover),
              if (dateLabel.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    color: Colors.black.withValues(alpha: 0.32),
                    child: Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardImage extends StatelessWidget {
  final RewardProgressDto reward;
  final BoxFit fit;

  const _RewardImage({required this.reward, required this.fit});

  @override
  Widget build(BuildContext context) {
    final imageUrl = reward.imageUrl;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: fit,
        errorBuilder: (_, __, ___) => const _BrokenGalleryImage(),
      );
    }

    return Image.asset(
      reward.assetPath,
      fit: fit,
      errorBuilder: (_, __, ___) => const _BrokenGalleryImage(),
    );
  }
}

class _BrokenGalleryImage extends StatelessWidget {
  const _BrokenGalleryImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: _ProfileGalleryPageState._surfaceSoft,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: _ProfileGalleryPageState._primary,
        ),
      ),
    );
  }
}
