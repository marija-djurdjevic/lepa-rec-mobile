// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Sagledaj';

  @override
  String get login => 'Prijava';

  @override
  String get loginWithGoogle => 'Prijavite se preko Google-a';

  @override
  String get logout => 'Odjava';

  @override
  String get welcome => 'Dobro došli';

  @override
  String get primerWelcomeTitle => 'Mir, vežba, rast';

  @override
  String get primerWelcomeDescription => 'Smestite se negde gde vam je prijatno i gde vas niko neće prekidati. Ovo je vaše vreme, zaslužujete ga.';

  @override
  String get proceed => 'Započnite pripremu';

  @override
  String get breathingExercise => 'Disanjem do mira';

  @override
  String get breathIn => 'Udahnite';

  @override
  String get breathOut => 'Izdahnite';

  @override
  String get pauseBreathing => 'Pauza';

  @override
  String breatheInForSeconds(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'Udiši $secondsString sekundi';
  }

  @override
  String breatheOutForSeconds(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'Izdiši $secondsString sekundi';
  }

  @override
  String get holdYourBreath => 'Zadržite dah';

  @override
  String get rounds => 'Krugovi';

  @override
  String get complete => 'Završi';

  @override
  String get sessionComplete => 'Svaka čast, učinio/la si nešto divno za sebe!';

  @override
  String get sessionCompleteMessage => 'Završio/la si vežbu disanja. Idemo dalje!';

  @override
  String get continueToNext => 'Nastavi';

  @override
  String get conclude => 'Zaključi';

  @override
  String get wrapUp => 'Zaokruži';

  @override
  String get home => 'Početna';

  @override
  String get dashboard => 'Današnji izazov';

  @override
  String get loadingSession => 'Učitavanje...';

  @override
  String get valueStatementTitle => 'Šta najviše rezonuje\nsa vama danas?';

  @override
  String get growthMessageTitle => 'Poruka za vas';

  @override
  String get completePrimer => 'Završi pripremu';

  @override
  String get errorLoadingStatements => 'Greška pri učitavanju iskaza';

  @override
  String get failedLoadValueStatements => 'Neuspešno učitavanje iskaza';

  @override
  String get errorLoadingMessage => 'Greška pri učitavanju poruke';

  @override
  String get failedLoadGrowthMessage => 'Neuspešno učitavanje poruke rasta';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get errorRenderingGrowthMessage => 'Greška pri prikazivanju ekrana poruke rasta';

  @override
  String get errorInSessionFlowPage => 'Greška pri prikazivanju ekrana toka sesije';

  @override
  String get distancedJournal => 'Sagledavanje sebe';

  @override
  String get yourAnswer => 'Tvoj odgovor';

  @override
  String get followUpAnswer => 'Tvoj odgovor';

  @override
  String get answerRequired => 'Ovo polje je obavezno';

  @override
  String get photoLimitMessage => 'Možete dodati najviše 3 fotografije.';

  @override
  String get submit => 'Pošalji';

  @override
  String get errorLoadingPlan => 'Greška pri učitavanju današnjeg plana';

  @override
  String get unknownError => 'Nepoznata greška';

  @override
  String get noTasksToday => 'Nema zadataka danas';

  @override
  String get completedAllTasks => 'Odličan posao! Završio/la si sve dostupne zadatke.';

  @override
  String get todaysPractice => 'Današnji izazov';

  @override
  String tasksToComplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'zadataka',
      one: 'zadatak',
    );
    return '$_temp0 za rad';
  }

  @override
  String get yourTasks => 'Tvoji zadaci';

  @override
  String get reflection => 'Sagledavanje dnevnika';

  @override
  String get reflectionFreshEyes => 'Ispitaj sa svežim očima zapise iz svog dnevnika';

  @override
  String get perspectiveScenario => 'Sagledavanje drugih';

  @override
  String get perspectiveScenarioPromptLabel => 'Scenario';

  @override
  String get levelEasy => 'Lako';

  @override
  String get levelMedium => 'Umereno';

  @override
  String get levelHard => 'Teško';

  @override
  String get answerEachScenarioQuestion => 'Odgovori na svako pitanje pre nego što otkriješ završnu perspektivu.';

  @override
  String scenarioQuestionNumber(int number) {
    return 'Pitanje $number';
  }

  @override
  String get perspectiveRevealTitle => 'Šta je iza kulisa ove priče?';

  @override
  String get perspectiveRevealHint => 'Zamislite se nad vašim odgovorima i pretpostavkama koje ste pravili.';

  @override
  String get perspectiveRevealSubtitle => 'Evo perspektive koja se otkriva nakon ovog scenarija.';

  @override
  String errorSubmittingPerspectiveScenario(String error) {
    return 'Greška pri slanju scenarija perspektive: $error';
  }

  @override
  String get comingSoon => 'Uskoro dostupno';

  @override
  String get chooseJournalChallenge => 'Izaberi temu o kojoj ćeš pisati danas';

  @override
  String get selectAvailablePrompts => 'Izaberi jedno od dostupnih pitanja koja te privlači. Nivoi težine ti pomažu da pronađeš pravi izazov.';

  @override
  String get journalCompletedToday => 'Dnevnik završen za danas';

  @override
  String get reflectionCompletedToday => 'Sagledavanje dnevnika završeno za danas';

  @override
  String get scenarioCompletedToday => 'Scenario završen za danas';

  @override
  String get exerciseNotInitialized => 'Greška: Vežba nije inicijalizovana';

  @override
  String get exerciseNotFoundOrOwned => 'Ova vežba nije dostupna ili nije povezana sa tvojim nalogom.';

  @override
  String get missingPrimerData => 'Nedostaju podaci za pripremu. Pokušaj ponovo.';

  @override
  String get responseSubmittedSuccessfully => 'Odgovor je uspešno poslat!';

  @override
  String errorSubmittingResponse(String error) {
    return 'Greška pri slanju odgovora: $error';
  }

  @override
  String get shareYourThoughts => 'Podeli svoje misli...';

  @override
  String get startingExercise => 'Pokretanje vežbe...';

  @override
  String get errorStartingExercise => 'Greška pri pokretanju vežbe';

  @override
  String get loadingPersonalizedMessage => 'Učitavanje poruke...';

  @override
  String errorCompletingPrimer(String error) {
    return 'Greška pri završavanju primerske faze: $error';
  }

  @override
  String get sessionFlowPageError => 'Greška tokom sesije';

  @override
  String get reflectionTitle => 'Sagledavanje dnevnika';

  @override
  String get reflectionPrompt => 'Da li imaš neki novi uvid na ovu temu?';

  @override
  String get reflectionGuidance => 'Ispitajte sa svežim očima zapis iz svog dnevnika.';

  @override
  String get reflectionFreshQuestion => 'Kako se osećate povodom napisanog? Šta su novi uvidi?';

  @override
  String get reflectionAfterTimeLabel => 'Posle nekog vremena, ovako ste razmišljali:';

  @override
  String get yesterdaysTopic => 'Jučerašnja tema';

  @override
  String get yourPreviousAnswer => 'Tvoj odgovor';

  @override
  String get previousFollowUpQuestion => 'Dodatno pitanje';

  @override
  String get yourPreviousFollowUpAnswer => 'Tvoj odgovor na pitanje';

  @override
  String get todayReflection => 'Današnje sagledavanje dnevnika';

  @override
  String get distancedJournalHint => 'Koristite „on“, „ona“ ili svoje ime umesto „ja“';

  @override
  String get journalFeedbackTitle => 'Povratna poruka';

  @override
  String get journalFeedbackSubtitle => 'Evo kratkog osvrta na način na koji si pisao/la';

  @override
  String get continueToDashboard => 'Nastavi';

  @override
  String get goodDistancingFeedback => 'Situaciju si opisao/la sa dobrom dozom distance. To može pomoći da je sagledaš mirnije i jasnije.';

  @override
  String get mixedDistancingFeedback => 'U pisanju se već vidi određena distanca. Sledeći put možeš još više govoriti o sebi kao o nekome sa strane.';

  @override
  String get needsMoreDistancingFeedback => 'Odgovor je ostao dosta blizu neposrednom doživljaju. Sledeći put pokušaj da događaj opišeš više kao da posmatraš nekoga sa strane.';

  @override
  String get reflectionRequired => 'Molim te podeli tvoj osvrt';

  @override
  String get reflectionSubmittedSuccessfully => 'Osvrt je uspešno poslat!';

  @override
  String get startBreathing => 'Dodirnite da započnete vežbu';

  @override
  String get beginWhenReady => '';

  @override
  String get getReady => 'Pripremi se';

  @override
  String errorSubmittingReflection(String error) {
    return 'Greška pri slanju osvrtanja: $error';
  }

  @override
  String get progress => 'Istorija';

  @override
  String get profile => 'Profil';

  @override
  String get dailySession => 'Dnevna vežba';

  @override
  String get close => 'Zatvori';
}
