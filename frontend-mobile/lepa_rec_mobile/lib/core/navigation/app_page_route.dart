import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  static const Duration transitionDurationValue = Duration(milliseconds: 500);
  static const Duration reverseTransitionDurationValue = Duration(milliseconds: 400);
  static const Curve transitionCurve = Curves.easeInOutQuart;
  static const Duration settleDelay = Duration(milliseconds: 100);
  static const Color fadeThroughColor = Color(0xFFF5F9F3);

  AppPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    Duration transitionDuration = transitionDurationValue,
    Duration reverseTransitionDuration = reverseTransitionDurationValue,
    Duration settleDelayDuration = settleDelay,
  }) : super(
          settings: settings,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final Animation<double> settle = CurvedAnimation(
              parent: animation,
              curve: Interval(
                settleDelayDuration.inMilliseconds / transitionDuration.inMilliseconds,
                1.0,
                curve: transitionCurve,
              ),
              reverseCurve: transitionCurve,
            );

            return Stack(
              children: [
                const ColoredBox(color: fadeThroughColor),
                FadeTransition(
                  opacity: settle,
                  child: child,
                ),
              ],
            );
          },
        );
}
