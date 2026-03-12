import 'package:flutter/material.dart';
import 'package:lepa_rec_mobile/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
