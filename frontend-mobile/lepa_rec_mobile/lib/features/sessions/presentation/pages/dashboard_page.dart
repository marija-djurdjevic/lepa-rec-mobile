import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/features/sessions/presentation/state/dashboard_view_state.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../data/dtos/distanced_journal_challenge_dto.dart';
import '../../data/dtos/perspective_scenario_prompt_dto.dart';
import '../../data/dtos/today_practice_plan_dto.dart';
import '../../data/dtos/today_practice_task_dto.dart';
import '../../data/repositories/session_repository.dart';
import 'distanced_journal_page.dart';
import 'perspective_scenario_page.dart';
import 'reflection_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final SessionRepository _sessionRepository;
  late DashboardViewState _viewState;

  bool _isCompletingSession = false;
  String? _activePracticeLang;

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _viewState = DashboardViewState(isLoading: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = _currentPracticeLang();
    if (_activePracticeLang == currentLang) return;
    _activePracticeLang = currentLang;
    _loadTodaysPlan();
  }

  bool _hasActiveTasks(TodayPracticePlanDto plan) {
    return (plan.reflectionPrompt != null && !plan.isReflectionCompleted) ||
        (plan.distancedJournalChoices.isNotEmpty &&
            !plan.isDistancedJournalCompleted) ||
        (plan.shouldShowPerspectiveScenario &&
            plan.perspectiveScenarioChoices.isNotEmpty &&
            !plan.isPerspectiveScenarioCompleted);
  }

  Future<void> _completeSessionIfNeeded(TodayPracticePlanDto plan) async {
    if (_isCompletingSession) return;

    final hasActiveTasks = _hasActiveTasks(plan);
    if (hasActiveTasks) return;

    _isCompletingSession = true;

    try {
      final sessionState = await _sessionRepository.getTodaySession();
      final status = sessionState.status.toLowerCase();
      if (status == 'completed' || status == 'abandoned') {
        return;
      }

      await _sessionRepository.completeSession();
    } catch (_) {
      // namjerno ne rušimo UX ako complete session ne uspije
    } finally {
      _isCompletingSession = false;
    }
  }

  Future<void> _loadTodaysPlan() async {
    final lang = _currentPracticeLang();
    try {
      final plan = await _sessionRepository.getTodaysPracticePlan(lang: lang);

      if (!mounted) return;

      setState(() {
        _viewState = DashboardViewState(
          isLoading: false,
          todayPlan: plan,
          errorMessage: null,
        );
      });

      await _completeSessionIfNeeded(plan);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _viewState = DashboardViewState(
          isLoading: false,
          todayPlan: null,
          errorMessage: e.toString(),
        );
      });
    }
  }

  void _handleReflectionTap() {
    if (_viewState.todayPlan?.reflectionPrompt == null) {
      return;
    }

    _navigateToReflection(_viewState.todayPlan!.reflectionPrompt!);
  }

  Future<void> _navigateToReflection(
    DistancedJournalReflectionPromptDto reflectionPrompt,
  ) async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReflectionPage(reflectionPrompt: reflectionPrompt),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadTodaysPlan();
    }
  }

  Future<void> _handleJournalTap(DistancedJournalChallengeDto challenge) async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => DistancedJournalPage(challenge: challenge),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadTodaysPlan();
    }
  }

  Future<void> _handlePerspectiveScenarioTap(
    PerspectiveScenarioPromptDto prompt,
  ) async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => PerspectiveScenarioPage(prompt: prompt),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadTodaysPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppTopBar(
        title: context.l10n.dashboard,
      ),
      body: _buildBody(),
    );
  }

  String _currentPracticeLang() {
    return Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr';
  }

  Widget _buildBody() {
    if (_viewState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B9B6E)),
        ),
      );
    }

    if (_viewState.errorMessage != null) {
      return _buildErrorState();
    }

    if (_viewState.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPlanContent();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.errorLoadingPlan,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B9B6E),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _viewState.errorMessage ?? context.l10n.unknownError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTodaysPlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9B6E),
            ),
            child: Text(
              context.l10n.retry,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.noTasksToday,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B9B6E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.completedAllTasks,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: const Color(0xFF6B9B6E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanContent() {
    final plan = _viewState.todayPlan!;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
          if (plan.reflectionPrompt != null && !plan.isReflectionCompleted)
            SliverToBoxAdapter(
              child: _buildReflectionTaskCard(plan.reflectionPrompt!),
            )
          else if (plan.isReflectionCompleted)
            SliverToBoxAdapter(child: _buildReflectionCompletedCard()),
          if (!plan.isDistancedJournalCompleted &&
              plan.distancedJournalChoices.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildDistancedJournalSection(
                plan.distancedJournalChoices,
              ),
            )
          else if (plan.isDistancedJournalCompleted)
            SliverToBoxAdapter(child: _buildDistancedJournalCompletedCard()),
          if (plan.shouldShowPerspectiveScenario &&
              plan.perspectiveScenarioChoices.isNotEmpty &&
              !plan.isPerspectiveScenarioCompleted)
            SliverToBoxAdapter(
              child: _buildPerspectiveScenarioSection(
                plan.perspectiveScenarioChoices,
              ),
            )
          else if (plan.isPerspectiveScenarioCompleted)
            SliverToBoxAdapter(child: _buildPerspectiveScenarioCompletedCard()),
          SliverToBoxAdapter(child: const SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildReflectionTaskCard(
    DistancedJournalReflectionPromptDto reflection,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: GestureDetector(
        onTap: _handleReflectionTap,
        child: Container(
          padding: const EdgeInsets.all(18),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF6B9B6E),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            context.l10n.reflection,
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B9B6E),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: const Color(0xFF6B9B6E),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.reflectionFreshEyes,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B9B6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reflection.challengeContent,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildPerspectiveScenarioSection(
    List<PerspectiveScenarioPromptDto> prompts,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.psychology_outlined,
                        color: Color(0xFF6B9B6E),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.perspectiveScenario,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B9B6E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 8),
              ...prompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPerspectiveScenarioChoiceOption(prompt),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerspectiveScenarioChoiceOption(
    PerspectiveScenarioPromptDto prompt,
  ) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _handlePerspectiveScenarioTap(prompt),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .secondary
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt.scenarioText,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(prompt.challengeLevel),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        _getLevelLabel(prompt.challengeLevel, context),
                        style: GoogleFonts.quicksand(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFF6B9B6E),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistancedJournalSection(
    List<DistancedJournalChallengeDto> challenges,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.description_outlined,
                        color: Color(0xFF6B9B6E),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.distancedJournal,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B9B6E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 8),
              ...challenges.map((challenge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildJournalChoiceOption(challenge),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalChoiceOption(DistancedJournalChallengeDto challenge) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _handleJournalTap(challenge),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .secondary
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.content,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(challenge.challengeLevel),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        _getLevelLabel(challenge.challengeLevel, context),
                        style: GoogleFonts.quicksand(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFF6B9B6E),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistancedJournalCompletedCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.distancedJournal,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionCompletedCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.reflection,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerspectiveScenarioCompletedCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.perspectiveScenario,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
}
