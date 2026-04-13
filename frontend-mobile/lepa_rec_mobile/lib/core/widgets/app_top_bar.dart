import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final bool showClose;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final String? backTooltip;
  final String? closeTooltip;
  final Color? backgroundColor;
  final bool centerTitle;

  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.showClose = false,
    this.onBack,
    this.onClose,
    this.backTooltip,
    this.closeTooltip,
    this.backgroundColor,
    this.centerTitle = true,
  }) : assert(!(showBack && showClose), 'Cannot show both back and close');

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    const Color appBarGreen = Color(0xFF6B9B6E);
    return AppBar(
      backgroundColor: backgroundColor ?? appBarGreen,
      elevation: 0,
      centerTitle: centerTitle,
      titleSpacing: 24,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      leading: _buildLeading(context),
      actions: _buildActions(context),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBack) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Theme.of(context).colorScheme.primary,
        tooltip: backTooltip,
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> baseActions = [
      if (actions != null) ...actions!,
      if (showClose)
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: closeTooltip,
          onPressed: onClose ?? () => Navigator.of(context).maybePop(),
        ),
    ];

    return _wrapActions(baseActions);
  }

  List<Widget>? _wrapActions(List<Widget>? actions) {
    if (actions == null || actions.isEmpty) return actions;

    return actions
        .map(
          (action) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: IconTheme.merge(
                data: const IconThemeData(color: Colors.white),
                child: TextButtonTheme(
                  data: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  child: DefaultTextStyle(
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    child: action,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}
