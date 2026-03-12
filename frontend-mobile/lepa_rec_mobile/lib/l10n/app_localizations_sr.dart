// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Lepa reč';

  @override
  String get login => 'Prijava';

  @override
  String get logout => 'Odjava';

  @override
  String get welcome => 'Dobro došli';

  @override
  String get primerWelcomeTitle => 'Dobro došli na putanju disanja';

  @override
  String get primerWelcomeDescription => 'Pronađi tiho mesto gde možeš biti prisutan/na sa sobom. Ovo je tvoje vreme.';

  @override
  String get proceed => 'Nastavi';

  @override
  String get breathingExercise => 'Vežba disanja';

  @override
  String get breathIn => 'Udahni';

  @override
  String get breathOut => 'Izdahni';

  @override
  String breatheInForSeconds(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'Udahni u toku $secondsString sekundi';
  }

  @override
  String breatheOutForSeconds(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'Izdahni u toku $secondsString sekundi';
  }

  @override
  String get holdYourBreath => 'Zadrži dah';

  @override
  String get rounds => 'Krugovi';

  @override
  String get complete => 'Završi';

  @override
  String get sessionComplete => 'Odličan posao!';

  @override
  String get sessionCompleteMessage => 'Zavrsio/la si vežbu disanja. Radiš neverovatno!';

  @override
  String get continueToNext => 'Nastavi';

  @override
  String get home => 'Početna';

  @override
  String get dashboard => 'Kontrolna tabla';

  @override
  String get loadingSession => 'Učitavanje...';

  @override
  String get valueStatementTitle => 'Šta je za tebe najvažnije?';

  @override
  String get growthMessageTitle => 'Tvoja Poruka Rasta';

  @override
  String get completePrimer => 'Završi Pripremu';

  @override
  String get errorLoadingStatements => 'Greška pri Učitavanju Iskaza';

  @override
  String get failedLoadValueStatements => 'Neuspešno učitavanje vrednosnih iskaza';

  @override
  String get errorLoadingMessage => 'Greška pri Učitavanju Poruke';

  @override
  String get failedLoadGrowthMessage => 'Neuspešno učitavanje poruke rasta';

  @override
  String get retry => 'Pokušaj Ponovo';

  @override
  String get errorRenderingGrowthMessage => 'Greška pri Crtanju Ekrana Poruke Rasta';

  @override
  String get errorInSessionFlowPage => 'Greška u Ekranu Toka Sesije';
}
