import 'package:flutter/material.dart';
import 'package:lepa_rec_mobile/features/sessions/presentation/state/primer_flow_state.dart';

import '../../../../core/localization/localization_extension.dart';
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

  @override
  Widget build(BuildContext context) {
    try {
      late final Widget pageWidget;

      switch (_currentStep) {
        case SessionFlowStep.primerWelcome:
          pageWidget = PrimerWelcomePage(onProceed: _moveToNext);
        case SessionFlowStep.breathingExercise:
          pageWidget = BreathingExercisePage(onComplete: _moveToNext);
        case SessionFlowStep.valueStatement:
          pageWidget = ValueStatementPage(
            onComplete: _moveToNext,
            onStateUpdate: _updatePrimerFlowState,
            primerFlowState: _primerFlowState,
          );
        case SessionFlowStep.growthMessage:
          pageWidget = GrowthMessagePage(
            onComplete: _moveToNext,
            onStateUpdate: _updatePrimerFlowState,
            primerFlowState: _primerFlowState,
          );
        case SessionFlowStep.complete:
          pageWidget = Scaffold(
            body: Center(child: Text(context.l10n.complete)),
          );
      }

      return pageWidget;
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
              const SizedBox(height: 16),
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
