import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_top_bar.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: context.l10n.progress),
      body: SafeArea(
        child: Center(
          child: Text(context.l10n.progress),
        ),
      ),
    );
  }
}
