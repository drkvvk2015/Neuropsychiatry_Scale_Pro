// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'நியூரோஸ்கேல் புரோ';

  @override
  String get dashboardTitle => 'நியூரோஸ்கேல் புரோ';

  @override
  String get analyticsTitle => 'பகுப்பாய்வு மற்றும் ஆய்வு';

  @override
  String get analytics => 'பகுப்பாய்வு';

  @override
  String get refresh => 'புதுப்பிக்க';

  @override
  String get searchPatients => 'நோயாளிகளை தேடுங்கள்...';

  @override
  String criticalPatientsBanner(int count) {
    return '$count நோயாளிக்கு உடனடி கவனம் தேவை';
  }

  @override
  String get total => 'மொத்தம்';

  @override
  String get assessed => 'மதிப்பீடு';

  @override
  String get urgent => 'அவசரம்';

  @override
  String get patients => 'நோயாளிகள்';

  @override
  String get assessments => 'மதிப்பீடுகள்';

  @override
  String get highRisk => 'உயர் ஆபத்து';

  @override
  String get icuMode => 'ICU முறை';

  @override
  String get addPatient => 'நோயாளி சேர்க்க';

  @override
  String get patientNameRequired => 'நோயாளி பெயர் *';

  @override
  String get patientName => 'நோயாளி பெயர்';

  @override
  String get ageRequired => 'வயது *';

  @override
  String get age => 'வயது';

  @override
  String get gender => 'பாலினம்';

  @override
  String get male => 'ஆண்';

  @override
  String get female => 'பெண்';

  @override
  String get other => 'மற்றவை';

  @override
  String get diagnosis => 'நோயறிதல்';

  @override
  String get wardUnit => 'வார்டு / பிரிவு';

  @override
  String get cancel => 'ரத்து';

  @override
  String get save => 'சேமிக்க';

  @override
  String get delete => 'நீக்கு';

  @override
  String get deletePatientTitle => 'நோயாளியை நீக்கவா?';

  @override
  String get deletePatientBody =>
      'இந்த நோயாளியின் அனைத்து பதிவுகளும் நீக்கப்படும். இதை மீட்டெடுக்க முடியாது.';

  @override
  String get noPatientsYet =>
      'இன்னும் நோயாளிகள் இல்லை\n+ ஐ தட்டி நோயாளியை சேர்க்கவும்';

  @override
  String noPatientsMatch(String query) {
    return '\"$query\" உடன் பொருந்தும் நோயாளிகள் இல்லை';
  }

  @override
  String get patientNotFound => 'நோயாளி கிடைக்கவில்லை';

  @override
  String get scalesTab => 'அளவைகள்';

  @override
  String get aiSummaryTab => 'AI சுருக்கம்';

  @override
  String get drugsTab => 'மருந்துகள்';

  @override
  String get risk => 'ஆபத்து';

  @override
  String get urgentClinicalAttention => 'உடனடி மருத்துவ கவனம் தேவை';

  @override
  String get completeScaleForSummary =>
      'AI சுருக்கத்தை உருவாக்க குறைந்தது ஒரு அளவையை முடிக்கவும்';

  @override
  String get aiVerifyNotice =>
      'AI உருவாக்கியது. மருத்துவ முடிவுடன் சரிபார்க்கவும்.';

  @override
  String get addDiagnosisForDrugs =>
      'மருந்து பரிந்துரைகளைப் பார்க்க நோயறிதலைச் சேர்க்கவும்';

  @override
  String get firstLine => 'முதல் வரிசை';

  @override
  String get secondLineAlternatives => 'இரண்டாம் வரிசை / மாற்றுகள்';

  @override
  String get adjuncts => 'துணை மருந்துகள்';

  @override
  String get guidelineOnly =>
      'இவை வழிகாட்டி அடிப்படையிலான பரிந்துரைகள். அளவு மற்றும் எதிர்விளைவுகளை உறுதிசெய்யவும்.';

  @override
  String get editPatient => 'நோயாளியைத் திருத்து';

  @override
  String scoreLabel(String score) {
    return 'மதிப்பெண்: $score';
  }

  @override
  String scoreWithMaxLabel(int score, int max) {
    return 'மதிப்பெண்: $score / $max';
  }

  @override
  String get tapToAssess => 'மதிப்பிட தட்டவும்';

  @override
  String get voiceInput => 'குரல் உள்ளீடு';

  @override
  String get saveAssessment => 'மதிப்பீட்டை சேமிக்க';

  @override
  String get suicideRiskDetected =>
      'தற்கொலை ஆபத்து கண்டறியப்பட்டது — உடனடி மதிப்பீடு தேவை';

  @override
  String savedAssessmentSnack(String scale, int score, String severity) {
    return '$scale சேமிக்கப்பட்டது — மதிப்பெண்: $score, $severity';
  }

  @override
  String get suicideRiskAlertTitle => 'தற்கொலை ஆபத்து எச்சரிக்கை';

  @override
  String cssrsRiskLevel(String risk) {
    return 'C-SSRS ஆபத்து நிலை: $risk';
  }

  @override
  String get suicideProtocolBullets =>
      '• நோயாளியை தனியாக விடாதீர்கள்\n• உடனே சிகிச்சை மனநல மருத்துவருக்கு தெரிவிக்கவும்\n• அவசர மனநல மதிப்பீட்டை பரிசீலிக்கவும்\n• உயிர்க்கு ஆபத்தான பொருட்களுக்கு அணுகலை நீக்கவும்\n• பாதுகாப்பு நடைமுறையை செயல்படுத்தவும்';

  @override
  String get acknowledged => 'உறுதிப்படுத்தப்பட்டது';

  @override
  String get stepOneOfThree => 'படி 1 / 3';

  @override
  String get stepTwoOfThree => 'படி 2 / 3';

  @override
  String get stepSelectPatient => 'நோயாளியைத் தேர்வு செய்க';

  @override
  String get stepSelectScale => 'அளவையைத் தேர்வு செய்க';

  @override
  String get stepScoreItems => 'உருப்படிகளை மதிப்பிடுக';

  @override
  String get stepReviewResult => 'விளைவை மதிப்பாய்வு செய்க';

  @override
  String get noPatientsFoundAddFromDashboard =>
      'நோயாளிகள் இல்லை.\nடாஷ்போர்டில் இருந்து நோயாளிகளைச் சேர்க்கவும்.';

  @override
  String savedIcuSnack(String scale, int score) {
    return 'சேமிக்கப்பட்டது: $scale — மதிப்பெண்: $score';
  }

  @override
  String get reset => 'மீட்டமை';

  @override
  String get patientTrendChart => 'நோயாளி மதிப்பெண் போக்கு';

  @override
  String get patient => 'நோயாளி';

  @override
  String get scale => 'அளவை';

  @override
  String get noDataForSelection =>
      'தேர்ந்தெடுக்கப்பட்ட நோயாளி/அளவைக்கு தரவு இல்லை';

  @override
  String get severityDistributionWard => 'கடுமைத்தன்மை பகிர்வு (வார்டு)';

  @override
  String get scaleUsage => 'அளவை பயன்பாடு';

  @override
  String get noAnalyticsData =>
      'இன்னும் தரவு இல்லை\nபகுப்பாய்வைப் பார்க்க நோயாளிகளை மதிப்பிடுங்கள்';

  @override
  String get exportCsv => 'CSV ஏற்றுமதி';

  @override
  String get exportSubject => 'நியூரோஸ்கேல் புரோ — தரவு ஏற்றுமதி';

  @override
  String exportFailed(String error) {
    return 'ஏற்றுமதி தோல்வி: $error';
  }

  @override
  String get criticalAlertTitle => 'அவசர எச்சரிக்கை';

  @override
  String get highRiskTitle => 'உயர் ஆபத்து';

  @override
  String patientLabel(String name) {
    return 'நோயாளி: $name';
  }

  @override
  String get emergencyDialogBody =>
      'உடனடி மனநல மதிப்பீடு தேவை.\nநோயாளியை கவனிக்காமல் விடாதீர்கள்.\nசிகிச்சை அணிக்கு உடனே தெரிவிக்கவும்.';

  @override
  String get acknowledge => 'உறுதிப்படுத்து';

  @override
  String get modelManager => 'மாதிரி மேலாளர்';

  @override
  String get modelManagerHint =>
      'ஆதரிக்கப்படும் மொழிகளுக்கான ஆஃப்லைன் குரல் மாதிரி மாற்றங்களை நிர்வகிக்கவும்.';

  @override
  String get bundledModel => 'உட்பொதிக்கப்பட்ட மாதிரி';

  @override
  String get importedModel => 'இறக்குமதி செய்யப்பட்ட மாதிரி';

  @override
  String get importModel => 'மாதிரி இறக்குமதி';

  @override
  String get clearModel => 'இறக்குமதி மாதிரியை நீக்கு';

  @override
  String get importNotSupportedWeb =>
      'நேரடி மாதிரி இறக்குமதி நிறுவப்பட்ட பயன்பாடுகளில் கிடைக்கும். வலைப் பயன்பாடு உட்பொதிக்கப்பட்ட குரல் வளங்களைப் பயன்படுத்தும்.';

  @override
  String modelImportSuccess(String language) {
    return '$language க்கான மாதிரி இறக்குமதி செய்யப்பட்டது';
  }

  @override
  String modelImportFailed(String error) {
    return 'மாதிரி இறக்குமதி தோல்வி: $error';
  }

  @override
  String get storageEncrypted => 'குறியாக்கப்பட்ட SQLite';

  @override
  String get storageBrowser => 'உலாவி சேமிப்பு';

  @override
  String get responsiveModePhone => 'தொலைபேசி';

  @override
  String get responsiveModeTablet => 'டாப்லெட்';

  @override
  String get responsiveModeDesktop => 'டெஸ்க்டாப்';

  @override
  String get noRisk => 'ஆபத்து இல்லை';

  @override
  String get lowRisk => 'குறைந்த ஆபத்து';

  @override
  String get moderateRisk => 'மிதமான ஆபத்து';

  @override
  String get highRiskLabel => 'உயர் ஆபத்து';

  @override
  String get criticalRisk => 'முக்கிய ஆபத்து';

  @override
  String get normal => 'சாதாரணம்';

  @override
  String get mild => 'லேசான';

  @override
  String get moderate => 'மிதமான';

  @override
  String get severe => 'கடுமையான';

  @override
  String get verySevere => 'மிகக் கடுமையான';

  @override
  String get wardFallback => 'OPD';
}
