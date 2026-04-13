import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../widgets/breathing_circle.dart';

class BreathingExercisePage extends StatefulWidget {
  final VoidCallback onComplete;

  const BreathingExercisePage({
    super.key,
    required this.onComplete,
  });

  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _timerController;
  late final AnimationController _phaseBlendController;

  Timer? _countdownTimer;
  Timer? _preStartTimer;
  Timer? _completionTimer;

  static const int _totalRounds = 3;
  static const int _breathInDuration = 4;
  static const int _holdDuration = 4;
  static const int _breathOutDuration = 4;
  static const int _pauseDuration = 4;
  static const int _preStartCountdownDuration = 3;
  static const double _centerContentHeight = 120;

  int _currentRound = 0;
  BreathingPhase _currentPhase = BreathingPhase.breathIn;
  BreathingPhase _previousPhase = BreathingPhase.breathIn;
  int _secondsLeft = _breathInDuration;
  int _preStartCountdown = _preStartCountdownDuration;

  bool _isCompleted = false;
  bool _exerciseCompleted = false;
  bool _hasStarted = false;
  bool _isPreStartCountdownActive = false;
  bool _showCompletion = false;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(vsync: this);
    _timerController = AnimationController(vsync: this)
      ..addStatusListener(_onAnimationStatusChanged);
    _phaseBlendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..value = 1.0;
  }

  int _getPhaseDuration(BreathingPhase phase) {
    return switch (phase) {
      BreathingPhase.breathIn => _breathInDuration,
      BreathingPhase.hold => _holdDuration,
      BreathingPhase.breathOut => _breathOutDuration,
      BreathingPhase.pause => _pauseDuration,
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
          _previousPhase = BreathingPhase.breathIn;
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

    if (_currentPhase == BreathingPhase.pause) {
      _currentRound++;
      if (_currentRound >= _totalRounds) {
        _completeExercise();
        return;
      }
    }

    setState(() {
      _previousPhase = _currentPhase;
      _currentPhase = switch (_currentPhase) {
        BreathingPhase.breathIn => BreathingPhase.hold,
        BreathingPhase.hold => BreathingPhase.breathOut,
        BreathingPhase.breathOut => BreathingPhase.pause,
        BreathingPhase.pause => BreathingPhase.breathIn,
      };
    });
    _phaseBlendController.forward(from: 0);

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
    setState(() {
      _showCompletion = true;
    });

    _completionTimer?.cancel();
    _completionTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _preStartTimer?.cancel();
    _completionTimer?.cancel();
    _timerController.removeStatusListener(_onAnimationStatusChanged);
    _breathingController.dispose();
    _timerController.dispose();
    _phaseBlendController.dispose();
    super.dispose();
  }

  bool get _isIdle => !_hasStarted && !_isPreStartCountdownActive;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppTopBar(
        title: context.l10n.dailySession,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -8),
                    child: AnimatedScale(
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.easeInOutCubic,
                    scale: _isIdle ? 1.0 : 1.28,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 2000),
                      curve: Curves.easeInOutCubic,
                      opacity: _isIdle ? 1 : 0,
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _BreathingLinesPainter(),
                      ),
                    ),
                  ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(0, _isIdle ? 0 : 20),
                            child: BreathingCircle(
                              animation: _breathingController,
                              phase: _currentPhase,
                              previousPhase: _previousPhase,
                              phaseBlend: _phaseBlendController,
                              isIdle: _isIdle,
                              onTap: _isIdle ? _onStartPressed : null,
                              idleText: context.l10n.startBreathing,
                            ),
                          ),
                        ),
                      ),
                        const SizedBox(height: AppSpacing.xxl + AppSpacing.md),
                        Transform.translate(
                          offset: const Offset(0, 24),
                          child: SizedBox(
                            height: _centerContentHeight,
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: _buildCenterContent(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
      return const SizedBox(
        key: ValueKey('idle'),
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

    if (_showCompletion) {
      return const SizedBox(
        key: ValueKey('complete'),
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
      BreathingPhase.pause => context.l10n.holdYourBreath,
    };
  }
}

enum BreathingPhase { breathIn, hold, breathOut, pause }

class _BreathingLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF6B9B6E).withValues(alpha: 0.5);

    final Offset center = Offset(size.width / 2, size.height / 2 - 60);
    final double baseRadius = size.width * 0.42;

    void drawWavyRing(
      double radius,
      double amplitude,
      double phaseShift,
      int waves,
    ) {
      final Path path = Path();
      const int steps = 220;
      for (int i = 0; i <= steps; i++) {
        final double t = (i / steps) * math.pi * 2;
        final double wave = math.sin((t * waves) + phaseShift) * amplitude;
        final double r = radius + wave;
        final double x = center.dx + math.cos(t) * r;
        final double y = center.dy + math.sin(t) * r;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, linePaint);
    }

    drawWavyRing(baseRadius, size.width * 0.02, 0.0, 6);
    drawWavyRing(baseRadius + size.width * 0.06, size.width * 0.018, 1.2, 7);
    drawWavyRing(baseRadius + size.width * 0.12, size.width * 0.016, 2.3, 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
