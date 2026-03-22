import '../../data/models/today_practice_plan_dto.dart';

class DashboardViewState {
  final bool isLoading;
  final TodayPracticePlanDto? todayPlan;
  final String? errorMessage;

  DashboardViewState({
    this.isLoading = true,
    this.todayPlan,
    this.errorMessage,
  });

  DashboardViewState copyWith({
    bool? isLoading,
    TodayPracticePlanDto? todayPlan,
    String? errorMessage,
  }) {
    return DashboardViewState(
      isLoading: isLoading ?? this.isLoading,
      todayPlan: todayPlan ?? this.todayPlan,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isEmpty =>
      todayPlan == null ||
      (todayPlan!.reflectionPrompt == null &&
          todayPlan!.distancedJournalChoices.isEmpty &&
          todayPlan!.perspectiveScenarioPrompt == null &&
          !todayPlan!.isDistancedJournalCompleted &&
          !todayPlan!.isReflectionCompleted &&
          !todayPlan!.isPerspectiveScenarioCompleted);

  int get taskCount {
    if (todayPlan == null) return 0;
    int count = 0;

    if (todayPlan!.reflectionPrompt != null &&
        !todayPlan!.isReflectionCompleted) {
      count++;
    }
    if (todayPlan!.distancedJournalChoices.isNotEmpty &&
        !todayPlan!.isDistancedJournalCompleted) {
      count++;
    }
    if (todayPlan!.shouldShowPerspectiveScenario &&
        todayPlan!.perspectiveScenarioPrompt != null &&
        !todayPlan!.isPerspectiveScenarioCompleted) {
      count++;
    }
    return count;
  }

  @override
  String toString() =>
      'DashboardViewState(isLoading: $isLoading, todayPlan: $todayPlan, errorMessage: $errorMessage)';
}
