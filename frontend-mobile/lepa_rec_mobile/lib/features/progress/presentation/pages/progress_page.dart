import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../data/models/history_item.dart';
import '../../data/repositories/history_repository.dart';
import 'history_detail_page.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: context.l10n.progress),
      body: SafeArea(
        child: FutureBuilder<List<HistoryItem>>(
          future: HistoryRepository().getHistory(
            lang: Localizations.localeOf(context).languageCode == 'en'
                ? 'en'
                : 'sr',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                ),
              );
            }

            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return Center(
                child: Text(
                  context.l10n.progress,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B9B6E),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _HistoryCard(item: items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMM yyyy', 'sr_Latn')
        .format(item.submittedAt);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailPage(item: item),
          ),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6B9B6E), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _typeLabel(context),
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B9B6E),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.safePromptText,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF6B9B6E),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  dateLabel,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(BuildContext context) {
    switch (item.type) {
      case HistoryItemType.distancedJournal:
        return context.l10n.distancedJournal;
      case HistoryItemType.perspectiveScenario:
        return context.l10n.perspectiveScenario;
    }
  }
}
