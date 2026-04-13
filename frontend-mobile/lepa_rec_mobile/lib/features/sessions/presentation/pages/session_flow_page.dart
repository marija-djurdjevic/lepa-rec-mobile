import 'package:flutter/material.dart';
import 'package:lepa_rec_mobile/features/sessions/presentation/state/primer_flow_state.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../pages/breathing_exercise_page.dart';
import '../pages/growth_message_page.dart';
import '../pages/primer_welcome_page.dart';
import '../pages/value_statement_page.dart';

enum SessionFlowStep {
  primerWelcome,
  breathingExercise,
  valueStatement,
  growthMessage,
  complete,
}

class SessionFlowPage extends StatefulWidget {
  final VoidCallback onSessionComplete;

  const SessionFlowPage({super.key, required this.onSessionComplete});

  @override
  State<SessionFlowPage> createState() => _SessionFlowPageState();
}

class _SessionFlowPageState extends State<SessionFlowPage> {
  SessionFlowStep _currentStep = SessionFlowStep.primerWelcome;
  PrimerFlowState _primerFlowState = PrimerFlowState();

  void _moveToNext() {
    setState(() {
      _currentStep = switch (_currentStep) {
        SessionFlowStep.primerWelcome => SessionFlowStep.breathingExercise,
        SessionFlowStep.breathingExercise => SessionFlowStep.valueStatement,
        SessionFlowStep.valueStatement => SessionFlowStep.growthMessage,
        SessionFlowStep.growthMessage => SessionFlowStep.complete,
        SessionFlowStep.complete => SessionFlowStep.complete,
      };
    });

    if (_currentStep == SessionFlowStep.complete) {
      widget.onSessionComplete();
    }
  }

  void _updatePrimerFlowState(PrimerFlowState newState) {
    setState(() {
      _primerFlowState = newState;
    });
  }

  void _handleClose() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    try {
      late final Widget pageWidget;

      switch (_currentStep) {
        case SessionFlowStep.primerWelcome:
          pageWidget = PrimerWelcomePage(
            key: const ValueKey(SessionFlowStep.primerWelcome),
            onProceed: _moveToNext,
            onClose: _handleClose,
          );
        case SessionFlowStep.breathingExercise:
          pageWidget = BreathingExercisePage(
            key: const ValueKey(SessionFlowStep.breathingExercise),
            onComplete: _moveToNext,
            onClose: _handleClose,
          );
        case SessionFlowStep.valueStatement:
          pageWidget = ValueStatementPage(
            key: const ValueKey(SessionFlowStep.valueStatement),
            onComplete: _moveToNext,
            onStateUpdate: _updatePrimerFlowState,
            primerFlowState: _primerFlowState,
            onClose: _handleClose,
          );
        case SessionFlowStep.growthMessage:
          pageWidget = GrowthMessagePage(
            key: const ValueKey(SessionFlowStep.growthMessage),
            onComplete: _moveToNext,
            onStateUpdate: _updatePrimerFlowState,
            primerFlowState: _primerFlowState,
            onClose: _handleClose,
          );
        case SessionFlowStep.complete:
          pageWidget = Scaffold(
            key: const ValueKey(SessionFlowStep.complete),
            body: Center(child: Text(context.l10n.complete)),
          );
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 950),
        reverseDuration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeInOutQuart,
        switchOutCurve: Curves.easeInOutQuart,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            children: <Widget>[
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFF5F9F3)),
              ),
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: const Interval(
              200 / 950,
              1.0,
              curve: Curves.easeInOutQuart,
            ),
            reverseCurve: Curves.easeInOutQuart,
          );
          return FadeTransition(
            opacity: curved,
            child: child,
          );
        },
        child: pageWidget,
      );
    } catch (e) {
      return Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.sessionFlowPageError,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                e.toString(),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
