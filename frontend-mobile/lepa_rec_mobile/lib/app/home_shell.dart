import 'package:flutter/material.dart';

import '../core/localization/localization_extension.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/progress/presentation/pages/progress_page.dart';
import '../features/sessions/presentation/pages/dashboard_page.dart';

class HomeShell extends StatefulWidget {
  final VoidCallback? onLogout;

  const HomeShell({super.key, this.onLogout});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardPage(),
          const ProgressPage(),
          ProfilePage(onLogout: widget.onLogout),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) return;
            setState(() => _currentIndex = index);
          },
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showSelectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.psychology_outlined),
              activeIcon: const Icon(Icons.psychology),
              label: context.l10n.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history),
              label: context.l10n.progress,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: context.l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
