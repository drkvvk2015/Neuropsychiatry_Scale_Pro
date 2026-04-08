import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NeuroScale Pro'**
  String get appTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'NeuroScale Pro'**
  String get dashboardTitle;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Research'**
  String get analyticsTitle;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @searchPatients.
  ///
  /// In en, this message translates to:
  /// **'Search patients...'**
  String get searchPatients;

  /// No description provided for @criticalPatientsBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} patient(s) require urgent attention'**
  String criticalPatientsBanner(int count);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @assessed.
  ///
  /// In en, this message translates to:
  /// **'Assessed'**
  String get assessed;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @assessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get assessments;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @icuMode.
  ///
  /// In en, this message translates to:
  /// **'ICU Mode'**
  String get icuMode;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @patientNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Patient Name *'**
  String get patientNameRequired;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientName;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Age *'**
  String get ageRequired;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @wardUnit.
  ///
  /// In en, this message translates to:
  /// **'Ward / Unit'**
  String get wardUnit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Patient?'**
  String get deletePatientTitle;

  /// No description provided for @deletePatientBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all records for this patient. This action cannot be undone.'**
  String get deletePatientBody;

  /// No description provided for @noPatientsYet.
  ///
  /// In en, this message translates to:
  /// **'No patients yet\nTap + to add a patient'**
  String get noPatientsYet;

  /// No description provided for @noPatientsMatch.
  ///
  /// In en, this message translates to:
  /// **'No patients match \"{query}\"'**
  String noPatientsMatch(String query);

  /// No description provided for @patientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Patient not found'**
  String get patientNotFound;

  /// No description provided for @scalesTab.
  ///
  /// In en, this message translates to:
  /// **'Scales'**
  String get scalesTab;

  /// No description provided for @aiSummaryTab.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummaryTab;

  /// No description provided for @drugsTab.
  ///
  /// In en, this message translates to:
  /// **'Drugs'**
  String get drugsTab;

  /// No description provided for @risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get risk;

  /// No description provided for @urgentClinicalAttention.
  ///
  /// In en, this message translates to:
  /// **'Urgent clinical attention required'**
  String get urgentClinicalAttention;

  /// No description provided for @completeScaleForSummary.
  ///
  /// In en, this message translates to:
  /// **'Complete at least one scale\nto generate AI summary'**
  String get completeScaleForSummary;

  /// No description provided for @aiVerifyNotice.
  ///
  /// In en, this message translates to:
  /// **'AI-generated. Verify with clinical judgment.'**
  String get aiVerifyNotice;

  /// No description provided for @addDiagnosisForDrugs.
  ///
  /// In en, this message translates to:
  /// **'Add a diagnosis to see\ndrug suggestions'**
  String get addDiagnosisForDrugs;

  /// No description provided for @firstLine.
  ///
  /// In en, this message translates to:
  /// **'First-Line'**
  String get firstLine;

  /// No description provided for @secondLineAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Second-Line / Alternatives'**
  String get secondLineAlternatives;

  /// No description provided for @adjuncts.
  ///
  /// In en, this message translates to:
  /// **'Adjuncts'**
  String get adjuncts;

  /// No description provided for @guidelineOnly.
  ///
  /// In en, this message translates to:
  /// **'Guideline-based suggestions only. Always verify dosing and contraindications.'**
  String get guidelineOnly;

  /// No description provided for @editPatient.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get editPatient;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreLabel(String score);

  /// No description provided for @scoreWithMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score} / {max}'**
  String scoreWithMaxLabel(int score, int max);

  /// No description provided for @tapToAssess.
  ///
  /// In en, this message translates to:
  /// **'Tap to assess'**
  String get tapToAssess;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// No description provided for @saveAssessment.
  ///
  /// In en, this message translates to:
  /// **'Save Assessment'**
  String get saveAssessment;

  /// No description provided for @suicideRiskDetected.
  ///
  /// In en, this message translates to:
  /// **'Suicide risk detected — immediate evaluation needed'**
  String get suicideRiskDetected;

  /// No description provided for @savedAssessmentSnack.
  ///
  /// In en, this message translates to:
  /// **'{scale} saved — Score: {score}, {severity}'**
  String savedAssessmentSnack(String scale, int score, String severity);

  /// No description provided for @suicideRiskAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'SUICIDE RISK ALERT'**
  String get suicideRiskAlertTitle;

  /// No description provided for @cssrsRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'C-SSRS Risk Level: {risk}'**
  String cssrsRiskLevel(String risk);

  /// No description provided for @suicideProtocolBullets.
  ///
  /// In en, this message translates to:
  /// **'• Do NOT leave patient alone\n• Notify treating psychiatrist immediately\n• Consider emergency psychiatric evaluation\n• Remove access to lethal means\n• Activate safety protocol'**
  String get suicideProtocolBullets;

  /// No description provided for @acknowledged.
  ///
  /// In en, this message translates to:
  /// **'ACKNOWLEDGED'**
  String get acknowledged;

  /// No description provided for @stepOneOfThree.
  ///
  /// In en, this message translates to:
  /// **'Step 1 / 3'**
  String get stepOneOfThree;

  /// No description provided for @stepTwoOfThree.
  ///
  /// In en, this message translates to:
  /// **'Step 2 / 3'**
  String get stepTwoOfThree;

  /// No description provided for @stepSelectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select Patient'**
  String get stepSelectPatient;

  /// No description provided for @stepSelectScale.
  ///
  /// In en, this message translates to:
  /// **'Select Scale'**
  String get stepSelectScale;

  /// No description provided for @stepScoreItems.
  ///
  /// In en, this message translates to:
  /// **'Score Items'**
  String get stepScoreItems;

  /// No description provided for @stepReviewResult.
  ///
  /// In en, this message translates to:
  /// **'Review Result'**
  String get stepReviewResult;

  /// No description provided for @noPatientsFoundAddFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'No patients found.\nAdd patients from Dashboard.'**
  String get noPatientsFoundAddFromDashboard;

  /// No description provided for @savedIcuSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved: {scale} — Score: {score}'**
  String savedIcuSnack(String scale, int score);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @patientTrendChart.
  ///
  /// In en, this message translates to:
  /// **'Patient Score Trend'**
  String get patientTrendChart;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @scale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get scale;

  /// No description provided for @noDataForSelection.
  ///
  /// In en, this message translates to:
  /// **'No data for selected patient/scale'**
  String get noDataForSelection;

  /// No description provided for @severityDistributionWard.
  ///
  /// In en, this message translates to:
  /// **'Severity Distribution (Ward)'**
  String get severityDistributionWard;

  /// No description provided for @scaleUsage.
  ///
  /// In en, this message translates to:
  /// **'Scale Usage'**
  String get scaleUsage;

  /// No description provided for @noAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'No data yet\nAssess patients to see analytics'**
  String get noAnalyticsData;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportSubject.
  ///
  /// In en, this message translates to:
  /// **'NeuroScale Pro — Data Export'**
  String get exportSubject;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @criticalAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL ALERT'**
  String get criticalAlertTitle;

  /// No description provided for @highRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'HIGH RISK'**
  String get highRiskTitle;

  /// No description provided for @patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient: {name}'**
  String patientLabel(String name);

  /// No description provided for @emergencyDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Immediate psychiatric evaluation required.\nDo NOT leave patient unattended.\nAlert treating team immediately.'**
  String get emergencyDialogBody;

  /// No description provided for @acknowledge.
  ///
  /// In en, this message translates to:
  /// **'ACKNOWLEDGE'**
  String get acknowledge;

  /// No description provided for @modelManager.
  ///
  /// In en, this message translates to:
  /// **'Model Manager'**
  String get modelManager;

  /// No description provided for @modelManagerHint.
  ///
  /// In en, this message translates to:
  /// **'Manage offline speech model overrides for supported languages.'**
  String get modelManagerHint;

  /// No description provided for @bundledModel.
  ///
  /// In en, this message translates to:
  /// **'Bundled model'**
  String get bundledModel;

  /// No description provided for @importedModel.
  ///
  /// In en, this message translates to:
  /// **'Imported model'**
  String get importedModel;

  /// No description provided for @importModel.
  ///
  /// In en, this message translates to:
  /// **'Import Model'**
  String get importModel;

  /// No description provided for @clearModel.
  ///
  /// In en, this message translates to:
  /// **'Clear Imported Model'**
  String get clearModel;

  /// No description provided for @importNotSupportedWeb.
  ///
  /// In en, this message translates to:
  /// **'Direct model import is available on installed apps. The web app uses bundled speech assets.'**
  String get importNotSupportedWeb;

  /// No description provided for @modelImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported model for {language}'**
  String modelImportSuccess(String language);

  /// No description provided for @modelImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Model import failed: {error}'**
  String modelImportFailed(String error);

  /// No description provided for @storageEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted SQLite'**
  String get storageEncrypted;

  /// No description provided for @storageBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser storage'**
  String get storageBrowser;

  /// No description provided for @responsiveModePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get responsiveModePhone;

  /// No description provided for @responsiveModeTablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get responsiveModeTablet;

  /// No description provided for @responsiveModeDesktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get responsiveModeDesktop;

  /// No description provided for @noRisk.
  ///
  /// In en, this message translates to:
  /// **'No Risk'**
  String get noRisk;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// No description provided for @moderateRisk.
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get moderateRisk;

  /// No description provided for @highRiskLabel.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRiskLabel;

  /// No description provided for @criticalRisk.
  ///
  /// In en, this message translates to:
  /// **'Critical Risk'**
  String get criticalRisk;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mild;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @verySevere.
  ///
  /// In en, this message translates to:
  /// **'Very Severe'**
  String get verySevere;

  /// No description provided for @wardFallback.
  ///
  /// In en, this message translates to:
  /// **'OPD'**
  String get wardFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
