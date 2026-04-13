import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  static const Duration transitionDurationValue = Duration(milliseconds: 950);
  static const Duration reverseTransitionDurationValue = Duration(milliseconds: 800);
  static const Curve transitionCurve = Curves.easeInOutQuart;
  static const Duration settleDelay = Duration(milliseconds: 200);
  static const Color fadeThroughColor = Color(0xFFF5F9F3);

  AppPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          transitionDuration: transitionDurationValue,
          reverseTransitionDuration: reverseTransitionDurationValue,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final Animation<double> settle = CurvedAnimation(
              parent: animation,
              curve: Interval(
                settleDelay.inMilliseconds / transitionDurationValue.inMilliseconds,
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
