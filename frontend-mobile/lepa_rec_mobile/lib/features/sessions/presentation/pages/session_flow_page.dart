import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/dtos/complete_primer_dto.dart';
import '../../data/dtos/growth_message_type.dart';
import '../pages/primer_welcome_page.dart';
import '../../data/repositories/session_repository.dart';

enum SessionFlowStep {
  primerWelcome,
  completingPrimer,
  complete,
}

class SessionFlowPage extends StatefulWidget {
  final VoidCallback onSessionComplete;

  const SessionFlowPage({super.key, required this.onSessionComplete});

  @override
  State<SessionFlowPage> createState() => _SessionFlowPageState();
}

class _SessionFlowPageState extends State<SessionFlowPage> {
  final SessionRepository _sessionRepository = SessionRepository();
  SessionFlowStep _currentStep = SessionFlowStep.primerWelcome;
  bool _isCompletingPrimer = false;
  String? _completePrimerError;

  Future<void> _completePrimerAndFinish() async {
    if (_isCompletingPrimer) return;

    setState(() {
      _currentStep = SessionFlowStep.completingPrimer;
      _isCompletingPrimer = true;
      _completePrimerError = null;
    });

    try {
      final lang = _currentPracticeLang();

      final statements = await _sessionRepository.getRandomPrimerStatements(
        lang: lang,
      );
      if (statements.isEmpty) {
        throw Exception('No primer statements available.');
      }

      final selectedStatement = statements.first;
      final presentedStatementIds = statements.map((s) => s.statementId).toList();

      final growthMessage = await _sessionRepository.getRandomGrowthMessage(
        type: GrowthMessageType.begin,
        selectedStatementId: selectedStatement.statementId,
        lang: lang,
      );

      final completePrimerDto = CompletePrimerDto(
        isSkipped: false,
        presentedStatementIds: presentedStatementIds,
        selectedStatementId: selectedStatement.statementId,
        growthMessageId: growthMessage.messageId,
      );

      await _sessionRepository.completePrimerWithData(completePrimerDto);
      if (!mounted) return;
      setState(() {
        _isCompletingPrimer = false;
        _currentStep = SessionFlowStep.complete;
      });
      widget.onSessionComplete();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCompletingPrimer = false;
        _completePrimerError = context.l10n.unknownError;
      });
    }
  }

  String _currentPracticeLang() {
    return Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'sr';
  }

  @override
  Widget build(BuildContext context) {
    try {
      late final Widget pageWidget;

      switch (_currentStep) {
        case SessionFlowStep.primerWelcome:
          pageWidget = PrimerWelcomePage(
            key: const ValueKey(SessionFlowStep.primerWelcome),
            onProceed: _completePrimerAndFinish,
          );
        case SessionFlowStep.completingPrimer:
          pageWidget = Scaffold(
            key: const ValueKey(SessionFlowStep.completingPrimer),
            body: Center(
              child: _completePrimerError == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _completePrimerError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: _completePrimerAndFinish,
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
            ),
          );
        case SessionFlowStep.complete:
          pageWidget = Scaffold(
            key: const ValueKey(SessionFlowStep.complete),
            body: Center(child: Text(context.l10n.complete)),
          );
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
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
            curve: Curves.easeInOutCubic,
            reverseCurve: Curves.easeInOutCubic,
          );
          final scale = Tween<double>(begin: 0.985, end: 1.0).animate(curved);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
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
