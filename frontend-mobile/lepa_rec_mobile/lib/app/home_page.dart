import 'package:flutter/material.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/sessions/presentation/pages/dashboard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPage(
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
