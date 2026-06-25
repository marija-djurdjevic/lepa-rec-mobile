import 'dart:math' as math;

import 'package:flutter/material.dart';

class RewardMosaicImage extends StatefulWidget {
  final String assetPath;
  final int unlockedPiecesCount;
  final int? previousUnlockedPiecesCount;
  final bool playPieceUnlockAnimation;
  final bool playCompletionAnimation;

  const RewardMosaicImage({
    super.key,
    required this.assetPath,
    required this.unlockedPiecesCount,
    this.previousUnlockedPiecesCount,
    this.playPieceUnlockAnimation = false,
    this.playCompletionAnimation = false,
  });

  @override
  State<RewardMosaicImage> createState() => _RewardMosaicImageState();
}

class _RewardMosaicImageState extends State<RewardMosaicImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _animationStartPieces = 0;

  int get _pieces => widget.unlockedPiecesCount.clamp(0, 4).toInt();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (_shouldAnimateUnlock) {
      _animationStartPieces = _initialAnimationStartPieces();
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant RewardMosaicImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldAnimateUnlock &&
        (oldWidget.playPieceUnlockAnimation !=
                widget.playPieceUnlockAnimation ||
            oldWidget.playCompletionAnimation !=
                widget.playCompletionAnimation ||
            oldWidget.assetPath != widget.assetPath ||
            oldWidget.unlockedPiecesCount != widget.unlockedPiecesCount)) {
      _animationStartPieces =
          widget.previousUnlockedPiecesCount?.clamp(0, 4).toInt() ??
          oldWidget.unlockedPiecesCount.clamp(0, 4).toInt();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _shouldAnimateUnlock ? _controller.value : 0.0;
        final seamOpacity = _pieces == 4
            ? (_shouldAnimateUnlock
                  ? 1 -
                        Curves.easeOutCubic.transform(
                          progress.clamp(0.0, 1.0).toDouble(),
                        )
                  : 0.0)
            : 1.0;
        final glowOpacity = _pieces == 4
            ? math.sin(progress * math.pi).clamp(0.0, 1.0).toDouble()
            : 0.0;
        final celebrationProgress = _pieces == 4
            ? ((progress - 0.62) / 0.38).clamp(0.0, 1.0).toDouble()
            : 0.0;
        final heldGlowOpacity = _pieces == 4
            ? math.sin(celebrationProgress * math.pi).clamp(0.0, 1.0).toDouble()
            : 0.0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            return Stack(
              fit: StackFit.expand,
              children: [
                for (var index = 0; index < 4; index++)
                  _RewardMosaicTile(
                    assetPath: widget.assetPath,
                    index: index,
                    fullSize: size,
                    isUnlocked: index < _pieces,
                    revealProgress: _pieceRevealProgress(index, progress),
                    flipProgress: _pieceFlipProgress(index, progress),
                    shineProgress: _pieceShineProgress(index, progress),
                    isNewlyUnlocked: _isNewlyUnlockedPiece(index),
                  ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _RewardMosaicOverlayPainter(
                      seamOpacity: seamOpacity,
                      glowOpacity: glowOpacity,
                      heldGlowOpacity: heldGlowOpacity,
                      sparkleProgress: celebrationProgress,
                      sweepProgress: progress,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool get _shouldAnimateUnlock =>
      widget.playPieceUnlockAnimation || widget.playCompletionAnimation;

  int _initialAnimationStartPieces() {
    final explicit = widget.previousUnlockedPiecesCount;
    if (explicit != null) return explicit.clamp(0, 4).toInt();
    return (_pieces - 1).clamp(0, 4).toInt();
  }

  bool _isNewlyUnlockedPiece(int index) {
    return index >= _animationStartPieces && index < _pieces;
  }

  double _pieceRevealProgress(int index, double progress) {
    if (index >= _pieces) return 0;
    if (index < _animationStartPieces) return 1;
    if (_shouldAnimateUnlock) {
      final revealIndex = index - _animationStartPieces;
      final start = revealIndex * 0.08;
      final value = ((progress - start) / 0.58).clamp(0.0, 1.0).toDouble();
      return Curves.easeOutBack.transform(value);
    }
    return 1;
  }

  double _pieceFlipProgress(int index, double progress) {
    if (!_isNewlyUnlockedPiece(index) || !_shouldAnimateUnlock) return 1;
    final revealIndex = index - _animationStartPieces;
    final start = 0.08 + revealIndex * 0.08;
    final value = ((progress - start) / 0.34).clamp(0.0, 1.0).toDouble();
    return Curves.easeOutCubic.transform(value);
  }

  double _pieceShineProgress(int index, double progress) {
    if (!_isNewlyUnlockedPiece(index) || !_shouldAnimateUnlock) return 0;
    final revealIndex = index - _animationStartPieces;
    final start = 0.30 + revealIndex * 0.08;
    final value = ((progress - start) / 0.42).clamp(0.0, 1.0).toDouble();
    return math.sin(value * math.pi).clamp(0.0, 1.0).toDouble();
  }
}

class _RewardMosaicTile extends StatelessWidget {
  final String assetPath;
  final int index;
  final Size fullSize;
  final bool isUnlocked;
  final double revealProgress;
  final double flipProgress;
  final double shineProgress;
  final bool isNewlyUnlocked;

  const _RewardMosaicTile({
    required this.assetPath,
    required this.index,
    required this.fullSize,
    required this.isUnlocked,
    required this.revealProgress,
    required this.flipProgress,
    required this.shineProgress,
    required this.isNewlyUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final row = index ~/ 2;
    final column = index % 2;
    final settleOffset = isUnlocked
        ? Offset(
            (column == 0 ? -1 : 1) * (1 - revealProgress) * 8,
            (row == 0 ? -1 : 1) * (1 - revealProgress) * 8,
          )
        : Offset.zero;

    final tileSize = Size(fullSize.width / 2, fullSize.height / 2);
    final croppedImage = Positioned(
      left: -column * tileSize.width,
      top: -row * tileSize.height,
      child: SizedBox(
        width: fullSize.width,
        height: fullSize.height,
        child: Image.asset(assetPath, fit: BoxFit.cover),
      ),
    );
    final imageContent = Stack(
      fit: StackFit.expand,
      children: [
        croppedImage,
        if (shineProgress > 0)
          CustomPaint(painter: _UnlockedPieceShinePainter(shineProgress)),
      ],
    );
    final tileContent = isUnlocked
        ? isNewlyUnlocked
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    _LockedMosaicPlaceholder(index: index),
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY((1 - flipProgress) * math.pi / 2),
                      child: Opacity(
                        opacity: revealProgress.clamp(0.0, 1.0),
                        child: imageContent,
                      ),
                    ),
                  ],
                )
              : imageContent
        : _LockedMosaicPlaceholder(index: index);

    return Positioned(
      left: column * tileSize.width,
      top: row * tileSize.height,
      width: tileSize.width,
      height: tileSize.height,
      child: ClipRect(
        child: Transform.translate(
          offset: settleOffset,
          child: Opacity(
            opacity: isUnlocked ? revealProgress.clamp(0.0, 1.0) : 1,
            child: tileContent,
          ),
        ),
      ),
    );
  }
}

class _LockedMosaicPlaceholder extends StatelessWidget {
  final int index;

  const _LockedMosaicPlaceholder({required this.index});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8EEE4), Color(0xFFD8E1D4), Color(0xFFC9D5C5)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _LockedMosaicPlaceholderPainter(index)),
          Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.42),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedPieceShinePainter extends CustomPainter {
  final double progress;

  const _UnlockedPieceShinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          const Color(0xFFFFE6A3).withValues(alpha: 0.34 * progress),
          Colors.transparent,
        ],
        stops: const [0.18, 0.5, 0.82],
      ).createShader(rect);
    canvas.drawRect(rect, glowPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFFD978).withValues(alpha: 0.78 * progress);
    canvas.drawRect(rect.deflate(1), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _UnlockedPieceShinePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _LockedMosaicPlaceholderPainter extends CustomPainter {
  final int index;

  const _LockedMosaicPlaceholderPainter(this.index);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.2;
    final shadowLinePaint = Paint()
      ..color = const Color(0xFF8FA38B).withValues(alpha: 0.08)
      ..strokeWidth = 1.2;

    for (double offset = -size.height; offset < size.width; offset += 18) {
      canvas.drawLine(
        Offset(offset, size.height),
        Offset(offset + size.height, 0),
        shadowLinePaint,
      );
      canvas.drawLine(
        Offset(offset + 5, size.height),
        Offset(offset + size.height + 5, 0),
        linePaint,
      );
    }

    final glowCenter = Offset(
      size.width * (index.isEven ? 0.32 : 0.68),
      size.height * (index < 2 ? 0.34 : 0.66),
    );
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.24),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: glowCenter,
              radius: size.shortestSide * 0.62,
            ),
          );
    canvas.drawCircle(glowCenter, size.shortestSide * 0.62, glowPaint);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 9; i++) {
      final x = ((i * 37 + index * 19) % 100) / 100 * size.width;
      final y = ((i * 29 + index * 31) % 100) / 100 * size.height;
      canvas.drawCircle(Offset(x, y), i.isEven ? 1.5 : 1.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LockedMosaicPlaceholderPainter oldDelegate) {
    return index != oldDelegate.index;
  }
}

class _RewardMosaicOverlayPainter extends CustomPainter {
  final double seamOpacity;
  final double glowOpacity;
  final double heldGlowOpacity;
  final double sparkleProgress;
  final double sweepProgress;

  const _RewardMosaicOverlayPainter({
    required this.seamOpacity,
    required this.glowOpacity,
    required this.heldGlowOpacity,
    required this.sparkleProgress,
    required this.sweepProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final seamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * seamOpacity)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      seamPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      seamPaint,
    );

    final rect = Offset.zero & size;
    final borderRect = rect.deflate(3);
    final borderRadius = RRect.fromRectAndRadius(
      borderRect,
      const Radius.circular(18),
    );

    if (heldGlowOpacity > 0) {
      final heldGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = const Color(
          0xFFE8B84B,
        ).withValues(alpha: 0.64 * heldGlowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(borderRadius, heldGlowPaint);

      final crispGoldPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(
          0xFFFFE6A3,
        ).withValues(alpha: 0.92 * heldGlowOpacity);
      canvas.drawRRect(borderRadius, crispGoldPaint);

      _drawSparkles(canvas, size, heldGlowOpacity, sparkleProgress);
    }

    if (glowOpacity <= 0) return;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFFFE6A3).withValues(alpha: glowOpacity),
          const Color(0xFFC9972E).withValues(alpha: glowOpacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 0.5, 0.62],
        transform: GradientRotation(sweepProgress * math.pi * 2),
      ).createShader(rect);

    canvas.drawRRect(borderRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _RewardMosaicOverlayPainter oldDelegate) {
    return seamOpacity != oldDelegate.seamOpacity ||
        glowOpacity != oldDelegate.glowOpacity ||
        heldGlowOpacity != oldDelegate.heldGlowOpacity ||
        sparkleProgress != oldDelegate.sparkleProgress ||
        sweepProgress != oldDelegate.sweepProgress;
  }

  void _drawSparkles(
    Canvas canvas,
    Size size,
    double opacity,
    double progress,
  ) {
    if (opacity <= 0) return;

    final sparklePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final points = <Offset>[
      Offset(size.width * 0.18, size.height * 0.08),
      Offset(size.width * 0.82, size.height * 0.12),
      Offset(size.width * 0.94, size.height * 0.32),
      Offset(size.width * 0.88, size.height * 0.74),
      Offset(size.width * 0.62, size.height * 0.93),
      Offset(size.width * 0.24, size.height * 0.9),
      Offset(size.width * 0.06, size.height * 0.58),
      Offset(size.width * 0.1, size.height * 0.24),
    ];

    for (var i = 0; i < points.length; i++) {
      final phase = ((progress * 1.8) + (i * 0.19)) % 1.0;
      final twinkle = math.sin(phase * math.pi).clamp(0.0, 1.0).toDouble();
      final sparkleOpacity = opacity * twinkle;
      if (sparkleOpacity <= 0.02) continue;

      final radius = 3.5 + (twinkle * 3.5);
      sparklePaint
        ..strokeWidth = 1.2 + twinkle
        ..color = (i.isEven ? const Color(0xFFFFEFC1) : Colors.white)
            .withValues(alpha: 0.78 * sparkleOpacity);

      final center = points[i];
      canvas.drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        sparklePaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        sparklePaint,
      );
    }
  }
}
