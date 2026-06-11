import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lepa_rec_mobile/features/sessions/presentation/state/dashboard_view_state.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/dtos/distanced_journal_challenge_dto.dart';
import '../../data/dtos/perspective_scenario_prompt_dto.dart';
import '../../data/dtos/today_practice_plan_dto.dart';
import '../../data/dtos/today_practice_task_dto.dart';
import '../../data/repositories/session_repository.dart';
import 'distanced_journal_page.dart';
import 'perspective_scenario_page.dart';
import 'reflection_page.dart';

const List<String> _dailyRewardAssets = <String>[
  'assets/images/rewards/reward_01.png',
  'assets/images/rewards/reward_02.png',
  'assets/images/rewards/reward_03.png',
  'assets/images/rewards/reward_04.png',
  'assets/images/rewards/reward_05.png',
  'assets/images/rewards/reward_06.png',
  'assets/images/rewards/reward_07.png',
  'assets/images/rewards/reward_08.png',
  'assets/images/rewards/reward_09.png',
  'assets/images/rewards/reward_10.png',
];

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final SessionRepository _sessionRepository;
  late final AuthLocalDataSource _authLocal;
  late DashboardViewState _viewState;

  bool _isCompletingSession = false;
  String? _activePracticeLang;
  String? _currentUserId;
  bool _distancedJournalCompletedLocally = false;
  bool _reflectionCompletedLocally = false;
  bool _perspectiveScenarioCompletedLocally = false;
  String? _distancedJournalCompletedDateKey;
  String? _reflectionCompletedDateKey;
  String? _perspectiveScenarioCompletedDateKey;
  String? _knownAvailableTasksDateKey;
  bool _distancedJournalWasAvailableToday = false;
  bool _reflectionWasAvailableToday = false;
  bool _perspectiveScenarioWasAvailableToday = false;
  DistancedJournalReflectionPromptDto? _lastReflectionPromptToday;
  List<DistancedJournalChallengeDto> _lastDistancedJournalChoicesToday =
      const [];
  List<PerspectiveScenarioPromptDto> _lastPerspectiveScenarioChoicesToday =
      const [];

  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _authLocal = AuthLocalDataSource();
    _viewState = DashboardViewState(isLoading: true);
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await _authLocal.readUserId();
    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
    });
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
      final fetchedPlan = await _sessionRepository.getTodaysPracticePlan(
        lang: lang,
      );
      final plan = _withLocalCompletionOverride(fetchedPlan);
      _rememberAvailableTasks(plan);
      if (kDebugMode) {
        debugPrint(
          '[dashboard][plan] '
          'lang=$lang '
          'journalCompleted=${plan.isDistancedJournalCompleted} '
          'journalChoices=${plan.distancedJournalChoices.length} '
          'reflectionCompleted=${plan.isReflectionCompleted} '
          'reflectionExists=${plan.reflectionPrompt != null} '
          'perspectiveCompleted=${plan.isPerspectiveScenarioCompleted} '
          'perspectiveChoices=${plan.perspectiveScenarioChoices.length} '
          'localJournalCompleted=$_distancedJournalCompletedLocally '
          'localReflectionCompleted=$_reflectionCompletedLocally '
          'localPerspectiveCompleted=$_perspectiveScenarioCompletedLocally',
        );
      }

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
      _reflectionCompletedLocally = true;
      _reflectionCompletedDateKey = _todayDateKey();
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
      _distancedJournalCompletedLocally = true;
      _distancedJournalCompletedDateKey = _todayDateKey();
      await _loadTodaysPlan();
    }
  }

  TodayPracticePlanDto _withLocalCompletionOverride(TodayPracticePlanDto plan) {
    _resetLocalTaskMemoryIfNeeded();

    final todayKey = _todayDateKey();
    final journalCompletedLocally =
        _distancedJournalCompletedLocally &&
        _distancedJournalCompletedDateKey == todayKey;
    final reflectionCompletedLocally =
        _reflectionCompletedLocally &&
        _reflectionCompletedDateKey == todayKey;
    final perspectiveCompletedLocally =
        _perspectiveScenarioCompletedLocally &&
        _perspectiveScenarioCompletedDateKey == todayKey;

    final shouldKeepJournalActive =
        _distancedJournalWasAvailableToday &&
        !journalCompletedLocally &&
        plan.isDistancedJournalCompleted;
    final shouldKeepReflectionActive =
        _reflectionWasAvailableToday &&
        !reflectionCompletedLocally &&
        plan.isReflectionCompleted;
    final shouldKeepPerspectiveActive =
        _perspectiveScenarioWasAvailableToday &&
        !perspectiveCompletedLocally &&
        plan.isPerspectiveScenarioCompleted;

    final reflectionPrompt = shouldKeepReflectionActive &&
            plan.reflectionPrompt == null
        ? _lastReflectionPromptToday
        : plan.reflectionPrompt;
    final distancedJournalChoices = shouldKeepJournalActive &&
            plan.distancedJournalChoices.isEmpty
        ? _lastDistancedJournalChoicesToday
        : plan.distancedJournalChoices;
    final perspectiveScenarioChoices = shouldKeepPerspectiveActive &&
            plan.perspectiveScenarioChoices.isEmpty
        ? _lastPerspectiveScenarioChoicesToday
        : plan.perspectiveScenarioChoices;

    final isDistancedJournalCompleted =
        journalCompletedLocally ||
        (_distancedJournalWasAvailableToday &&
            plan.isDistancedJournalCompleted &&
            !shouldKeepJournalActive);
    final isReflectionCompleted =
        reflectionCompletedLocally ||
        (plan.isReflectionCompleted && !shouldKeepReflectionActive);
    final isPerspectiveScenarioCompleted =
        perspectiveCompletedLocally ||
        (plan.isPerspectiveScenarioCompleted && !shouldKeepPerspectiveActive);

    return TodayPracticePlanDto(
      reflectionPrompt: reflectionPrompt,
      distancedJournalChoices: distancedJournalChoices,
      perspectiveScenarioChoices: perspectiveScenarioChoices,
      shouldShowPerspectiveScenario:
          plan.shouldShowPerspectiveScenario ||
          perspectiveScenarioChoices.isNotEmpty,
      isDistancedJournalCompleted: isDistancedJournalCompleted,
      isReflectionCompleted: isReflectionCompleted,
      isPerspectiveScenarioCompleted: isPerspectiveScenarioCompleted,
    );
  }

  void _rememberAvailableTasks(TodayPracticePlanDto plan) {
    _resetLocalTaskMemoryIfNeeded();

    if (plan.reflectionPrompt != null && !plan.isReflectionCompleted) {
      _reflectionWasAvailableToday = true;
      _lastReflectionPromptToday = plan.reflectionPrompt;
    }

    if (plan.distancedJournalChoices.isNotEmpty &&
        !plan.isDistancedJournalCompleted) {
      _distancedJournalWasAvailableToday = true;
      _lastDistancedJournalChoicesToday = plan.distancedJournalChoices;
    }

    if (plan.shouldShowPerspectiveScenario &&
        plan.perspectiveScenarioChoices.isNotEmpty &&
        !plan.isPerspectiveScenarioCompleted) {
      _perspectiveScenarioWasAvailableToday = true;
      _lastPerspectiveScenarioChoicesToday = plan.perspectiveScenarioChoices;
    }
  }

  void _resetLocalTaskMemoryIfNeeded() {
    final todayKey = _todayDateKey();
    if (_knownAvailableTasksDateKey == todayKey) {
      return;
    }

    _knownAvailableTasksDateKey = todayKey;
    _distancedJournalWasAvailableToday = false;
    _reflectionWasAvailableToday = false;
    _perspectiveScenarioWasAvailableToday = false;
    _lastReflectionPromptToday = null;
    _lastDistancedJournalChoicesToday = const [];
    _lastPerspectiveScenarioChoicesToday = const [];

    if (_distancedJournalCompletedDateKey != todayKey) {
      _distancedJournalCompletedLocally = false;
    }
    if (_reflectionCompletedDateKey != todayKey) {
      _reflectionCompletedLocally = false;
    }
    if (_perspectiveScenarioCompletedDateKey != todayKey) {
      _perspectiveScenarioCompletedLocally = false;
    }
  }

  String _todayDateKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  bool _shouldShowDistancedJournalCompleted(TodayPracticePlanDto plan) {
    return plan.isDistancedJournalCompleted &&
        (_distancedJournalCompletedLocally ||
            _distancedJournalWasAvailableToday);
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
      _perspectiveScenarioCompletedLocally = true;
      _perspectiveScenarioCompletedDateKey = _todayDateKey();
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

  String _rewardAssetForToday() {
    final userId = (_currentUserId != null && _currentUserId!.trim().isNotEmpty)
        ? _currentUserId!.trim()
        : 'guest';
    final dayIndex = _daysSinceEpoch();
    final userOffset = _stableHash(userId) % _dailyRewardAssets.length;
    final rewardIndex = (userOffset + dayIndex) % _dailyRewardAssets.length;
    return _dailyRewardAssets[rewardIndex];
  }

  int _daysSinceEpoch() {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    return normalized.difference(DateTime(2024, 1, 1)).inDays;
  }

  int _stableHash(String input) {
    var hash = 0;
    for (final codeUnit in input.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
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
    final showDailyReward = !_hasActiveTasks(plan);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
          if (showDailyReward)
            SliverToBoxAdapter(child: _buildDailyRewardCard()),
          if (!showDailyReward) ...[
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
            else if (_shouldShowDistancedJournalCompleted(plan))
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
              SliverToBoxAdapter(
                child: _buildPerspectiveScenarioCompletedCard(),
              ),
          ],
          SliverToBoxAdapter(child: const SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildDailyRewardCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6B9B6E).withValues(alpha: 0.26),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 9 / 14,
              child: Image.asset(
                _rewardAssetForToday(),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Text(
                context.l10n.dailyChallengeReward,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4E6752),
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
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
                  _reflectionCardText(reflection),
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
              ...challenges.take(2).map((challenge) {
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
                      _openingPromptText(challenge),
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

  String _openingPromptText(DistancedJournalChallengeDto challenge) {
    final content = challenge.content.trim();
    final opening = challenge.openingPromptText().trim();

    if (content.isEmpty) return opening;
    if (opening.isEmpty || opening == content) return content;
    return '$content\n\n$opening';
  }

  String _reflectionCardText(DistancedJournalReflectionPromptDto reflection) {
    final content = reflection.challengeContent.trim();
    if (content.isNotEmpty) return content;

    final question = reflection.reflectionQuestion?.trim();
    if (question != null && question.isNotEmpty) return question;
    return context.l10n.reflectionFreshQuestion;
  }
}
