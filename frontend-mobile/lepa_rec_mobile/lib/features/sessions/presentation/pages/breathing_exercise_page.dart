import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../widgets/breathing_circle.dart';

class BreathingExercisePage extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onClose;

  const BreathingExercisePage({
    super.key,
    required this.onComplete,
    required this.onClose,
  });

  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _timerController;

  Timer? _countdownTimer;
  Timer? _preStartTimer;

  static const int _totalRounds = 3;
  static const int _breathInDuration = 4;
  static const int _holdDuration = 4;
  static const int _breathOutDuration = 4;
  static const int _preStartCountdownDuration = 3;

  int _currentRound = 0;
  BreathingPhase _currentPhase = BreathingPhase.breathIn;
  int _secondsLeft = _breathInDuration;
  int _preStartCountdown = _preStartCountdownDuration;

  bool _isCompleted = false;
  bool _exerciseCompleted = false;
  bool _hasStarted = false;
  bool _isPreStartCountdownActive = false;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(vsync: this);
    _timerController = AnimationController(vsync: this)
      ..addStatusListener(_onAnimationStatusChanged);
  }

  int _getPhaseDuration(BreathingPhase phase) {
    return switch (phase) {
      BreathingPhase.breathIn => _breathInDuration,
      BreathingPhase.hold => _holdDuration,
      BreathingPhase.breathOut => _breathOutDuration,
    };
  }

  void _onStartPressed() {
    if (_hasStarted || _isPreStartCountdownActive || _isCompleted) return;

    setState(() {
      _isPreStartCountdownActive = true;
      _preStartCountdown = _preStartCountdownDuration;
    });

    _preStartTimer?.cancel();
    _preStartTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isCompleted) {
        timer.cancel();
        return;
      }

      if (_preStartCountdown > 1) {
        setState(() {
          _preStartCountdown--;
        });
      } else {
        timer.cancel();

        if (!mounted) return;

        setState(() {
          _isPreStartCountdownActive = false;
          _hasStarted = true;
          _currentRound = 0;
          _currentPhase = BreathingPhase.breathIn;
        });

        _startPhase();
      }
    });
  }

  void _startPhase() {
    if (!mounted || _isCompleted) return;

    final duration = _getPhaseDuration(_currentPhase);

    _countdownTimer?.cancel();

    _breathingController
      ..stop()
      ..reset()
      ..duration = Duration(seconds: duration);

    _timerController
      ..stop()
      ..reset()
      ..duration = Duration(seconds: duration);

    setState(() {
      _secondsLeft = duration;
    });

    _breathingController.forward();
    _timerController.forward();

    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isCompleted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
      }
    });
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isCompleted && _hasStarted) {
      _moveToNextPhase();
    }
  }

  void _moveToNextPhase() {
    if (!mounted || _isCompleted) return;

    if (_currentPhase == BreathingPhase.breathOut) {
      _currentRound++;
    }

    if (_currentPhase == BreathingPhase.breathOut &&
        _currentRound >= _totalRounds) {
      _completeExercise();
      return;
    }

    setState(() {
      _currentPhase = switch (_currentPhase) {
        BreathingPhase.breathIn => BreathingPhase.hold,
        BreathingPhase.hold => BreathingPhase.breathOut,
        BreathingPhase.breathOut => BreathingPhase.breathIn,
      };
    });

    _startPhase();
  }

  void _completeExercise() {
    if (_exerciseCompleted) {
      return;
    }

    _exerciseCompleted = true;
    _isCompleted = true;

    _countdownTimer?.cancel();
    _preStartTimer?.cancel();
    _breathingController.stop();
    _timerController.stop();

    if (!mounted) return;
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F9F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            dialogContext.l10n.sessionComplete,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B9B6E),
            ),
          ),
          content: Text(
            dialogContext.l10n.sessionCompleteMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
              height: 1.5,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    widget.onComplete();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    backgroundColor: const Color(0xFF6B9B6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                ),
                child: Text(
                  dialogContext.l10n.continueToNext,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _preStartTimer?.cancel();
    _timerController.removeStatusListener(_onAnimationStatusChanged);
    _breathingController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  bool get _isIdle => !_hasStarted && !_isPreStartCountdownActive;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppTopBar(
        title: context.l10n.dailySession,
        showClose: true,
        onClose: widget.onClose,
        closeTooltip: context.l10n.close,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.breathingExercise,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B9B6E),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BreathingCircle(
                    animation: _breathingController,
                    phase: _currentPhase,
                    isIdle: _isIdle,
                    onTap: _isIdle ? _onStartPressed : null,
                    idleText: context.l10n.startBreathing,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildCenterContent(),
                  ),
                ],
              ),
            ),
            if (_hasStarted || _isPreStartCountdownActive)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalRounds,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: index < _currentRound
                            ? const Color(0xFF6B9B6E)
                            : index == _currentRound
                            ? const Color(0x996B9B6E)
                            : const Color(0xFFD0D0D0),
                        child: index < _currentRound
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterContent() {
    if (_isIdle) {
      return Column(
        key: const ValueKey('idle'),
        children: [
          Text(
            context.l10n.beginWhenReady,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      );
    }

    if (_isPreStartCountdownActive) {
      return Column(
        key: const ValueKey('prestart'),
        children: [
          Text(
            '$_preStartCountdown',
            style: GoogleFonts.quicksand(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B9B6E),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.getReady,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      );
    }

    return Column(
      key: ValueKey(_currentPhase.name),
      children: [
        Text(
          '${_secondsLeft}s',
          style: GoogleFonts.quicksand(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6B9B6E),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          _getPhaseText(context, _currentPhase),
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  String _getPhaseText(BuildContext context, BreathingPhase phase) {
    return switch (phase) {
      BreathingPhase.breathIn => context.l10n.breathIn,
      BreathingPhase.hold => context.l10n.holdYourBreath,
      BreathingPhase.breathOut => context.l10n.breathOut,
    };
  }
}

enum BreathingPhase { breathIn, hold, breathOut }
