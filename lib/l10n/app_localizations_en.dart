// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NeuroScale Pro';

  @override
  String get dashboardTitle => 'NeuroScale Pro';

  @override
  String get analyticsTitle => 'Analytics & Research';

  @override
  String get analytics => 'Analytics';

  @override
  String get refresh => 'Refresh';

  @override
  String get searchPatients => 'Search patients...';

  @override
  String criticalPatientsBanner(int count) {
    return '$count patient(s) require urgent attention';
  }

  @override
  String get total => 'Total';

  @override
  String get assessed => 'Assessed';

  @override
  String get urgent => 'Urgent';

  @override
  String get patients => 'Patients';

  @override
  String get assessments => 'Assessments';

  @override
  String get highRisk => 'High Risk';

  @override
  String get icuMode => 'ICU Mode';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get patientNameRequired => 'Patient Name *';

  @override
  String get patientName => 'Patient Name';

  @override
  String get ageRequired => 'Age *';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get diagnosis => 'Diagnosis';

  @override
  String get wardUnit => 'Ward / Unit';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deletePatientTitle => 'Delete Patient?';

  @override
  String get deletePatientBody =>
      'This will delete all records for this patient. This action cannot be undone.';

  @override
  String get noPatientsYet => 'No patients yet\nTap + to add a patient';

  @override
  String noPatientsMatch(String query) {
    return 'No patients match \"$query\"';
  }

  @override
  String get patientNotFound => 'Patient not found';

  @override
  String get scalesTab => 'Scales';

  @override
  String get aiSummaryTab => 'AI Summary';

  @override
  String get drugsTab => 'Drugs';

  @override
  String get risk => 'Risk';

  @override
  String get urgentClinicalAttention => 'Urgent clinical attention required';

  @override
  String get completeScaleForSummary =>
      'Complete at least one scale\nto generate AI summary';

  @override
  String get aiVerifyNotice => 'AI-generated. Verify with clinical judgment.';

  @override
  String get addDiagnosisForDrugs => 'Add a diagnosis to see\ndrug suggestions';

  @override
  String get firstLine => 'First-Line';

  @override
  String get secondLineAlternatives => 'Second-Line / Alternatives';

  @override
  String get adjuncts => 'Adjuncts';

  @override
  String get guidelineOnly =>
      'Guideline-based suggestions only. Always verify dosing and contraindications.';

  @override
  String get editPatient => 'Edit Patient';

  @override
  String scoreLabel(String score) {
    return 'Score: $score';
  }

  @override
  String scoreWithMaxLabel(int score, int max) {
    return 'Score: $score / $max';
  }

  @override
  String get tapToAssess => 'Tap to assess';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get saveAssessment => 'Save Assessment';

  @override
  String get suicideRiskDetected =>
      'Suicide risk detected — immediate evaluation needed';

  @override
  String savedAssessmentSnack(String scale, int score, String severity) {
    return '$scale saved — Score: $score, $severity';
  }

  @override
  String get suicideRiskAlertTitle => 'SUICIDE RISK ALERT';

  @override
  String cssrsRiskLevel(String risk) {
    return 'C-SSRS Risk Level: $risk';
  }

  @override
  String get suicideProtocolBullets =>
      '• Do NOT leave patient alone\n• Notify treating psychiatrist immediately\n• Consider emergency psychiatric evaluation\n• Remove access to lethal means\n• Activate safety protocol';

  @override
  String get acknowledged => 'ACKNOWLEDGED';

  @override
  String get stepOneOfThree => 'Step 1 / 3';

  @override
  String get stepTwoOfThree => 'Step 2 / 3';

  @override
  String get stepSelectPatient => 'Select Patient';

  @override
  String get stepSelectScale => 'Select Scale';

  @override
  String get stepScoreItems => 'Score Items';

  @override
  String get stepReviewResult => 'Review Result';

  @override
  String get noPatientsFoundAddFromDashboard =>
      'No patients found.\nAdd patients from Dashboard.';

  @override
  String savedIcuSnack(String scale, int score) {
    return 'Saved: $scale — Score: $score';
  }

  @override
  String get reset => 'Reset';

  @override
  String get patientTrendChart => 'Patient Score Trend';

  @override
  String get patient => 'Patient';

  @override
  String get scale => 'Scale';

  @override
  String get noDataForSelection => 'No data for selected patient/scale';

  @override
  String get severityDistributionWard => 'Severity Distribution (Ward)';

  @override
  String get scaleUsage => 'Scale Usage';

  @override
  String get noAnalyticsData => 'No data yet\nAssess patients to see analytics';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportSubject => 'NeuroScale Pro — Data Export';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get criticalAlertTitle => 'CRITICAL ALERT';

  @override
  String get highRiskTitle => 'HIGH RISK';

  @override
  String patientLabel(String name) {
    return 'Patient: $name';
  }

  @override
  String get emergencyDialogBody =>
      'Immediate psychiatric evaluation required.\nDo NOT leave patient unattended.\nAlert treating team immediately.';

  @override
  String get acknowledge => 'ACKNOWLEDGE';

  @override
  String get modelManager => 'Model Manager';

  @override
  String get modelManagerHint =>
      'Manage offline speech model overrides for supported languages.';

  @override
  String get bundledModel => 'Bundled model';

  @override
  String get importedModel => 'Imported model';

  @override
  String get importModel => 'Import Model';

  @override
  String get clearModel => 'Clear Imported Model';

  @override
  String get importNotSupportedWeb =>
      'Direct model import is available on installed apps. The web app uses bundled speech assets.';

  @override
  String modelImportSuccess(String language) {
    return 'Imported model for $language';
  }

  @override
  String modelImportFailed(String error) {
    return 'Model import failed: $error';
  }

  @override
  String get storageEncrypted => 'Encrypted SQLite';

  @override
  String get storageBrowser => 'Browser storage';

  @override
  String get responsiveModePhone => 'Phone';

  @override
  String get responsiveModeTablet => 'Tablet';

  @override
  String get responsiveModeDesktop => 'Desktop';

  @override
  String get noRisk => 'No Risk';

  @override
  String get lowRisk => 'Low Risk';

  @override
  String get moderateRisk => 'Moderate Risk';

  @override
  String get highRiskLabel => 'High Risk';

  @override
  String get criticalRisk => 'Critical Risk';

  @override
  String get normal => 'Normal';

  @override
  String get mild => 'Mild';

  @override
  String get moderate => 'Moderate';

  @override
  String get severe => 'Severe';

  @override
  String get verySevere => 'Very Severe';

  @override
  String get wardFallback => 'OPD';
}
