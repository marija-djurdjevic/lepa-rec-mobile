import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../data/models/history_item.dart';
import '../../data/repositories/history_repository.dart';
import 'history_detail_page.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Future<List<HistoryItem>>? _historyFuture;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    _historyFuture = _loadHistory();
  }

  Future<List<HistoryItem>> _loadHistory() {
    return HistoryRepository().getHistory(
      lang: Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final tabSelf = isEnglish ? 'Seeing Yourself' : 'Sagledavanje sebe';
    final tabOthers = isEnglish ? 'Seeing Others' : 'Sagledavanje drugih';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6B9B6E),
          elevation: 0,
          centerTitle: true,
          title: Text(
            context.l10n.progress,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFFDDE9DD),
            labelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w700, fontSize: 14),
            tabs: [
              Tab(text: tabSelf),
              Tab(text: tabOthers),
            ],
          ),
        ),
        body: SafeArea(
          child: FutureBuilder<List<HistoryItem>>(
            future: _historyFuture,
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
              final selfItems = items.where((i) => i.type == HistoryItemType.distancedJournal).toList();
              final othersItems = items.where((i) => i.type == HistoryItemType.perspectiveScenario).toList();

              return TabBarView(
                children: [
                  _HistoryList(items: selfItems),
                  _HistoryList(items: othersItems),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<HistoryItem> items;

  const _HistoryList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          Localizations.localeOf(context).languageCode == 'en' ? 'No history yet.' : 'Još nema istorije.',
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
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMM yyyy', 'sr_Latn').format(item.submittedAt);

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
