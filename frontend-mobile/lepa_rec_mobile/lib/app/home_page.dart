import 'package:flutter/material.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import 'home_shell.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<String> onLanguageChanged;

  const HomePage({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HomeShell(
      onLanguageChanged: onLanguageChanged,
      onLogout: () async {
        final local = AuthLocalDataSource();
        await local.clearSession();
        if (context.mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (_) => false);
        }
      },
    );
  }
}
