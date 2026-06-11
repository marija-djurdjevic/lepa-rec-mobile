import 'package:flutter/material.dart';
import 'package:lepa_rec_mobile/core/notifications/push_notification_service.dart';

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
        await PushNotificationService.instance.unregisterCurrentTokenIfAny();
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
