import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

import '../core/constants.dart';

extension AppLocalizationsExt on AppLocalizations {
  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context)!;

  String severityLabel(String value) {
    switch (value) {
      case AppConstants.severityNormal:
        return normal;
      case AppConstants.severityMild:
        return mild;
      case AppConstants.severityModerate:
        return moderate;
      case AppConstants.severitySevere:
        return severe;
      case AppConstants.severityVerySevere:
        return verySevere;
      default:
        return value;
    }
  }

  String riskLabel(String value) {
    switch (value) {
      case AppConstants.riskNone:
        return noRisk;
      case AppConstants.riskLow:
        return lowRisk;
      case AppConstants.riskModerate:
        return moderateRisk;
      case AppConstants.riskHigh:
        return highRiskLabel;
      case AppConstants.riskCritical:
        return criticalRisk;
      default:
        return value;
    }
  }

  String genderLabel(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return male;
      case 'female':
        return female;
      case 'other':
        return other;
      default:
        return value;
    }
  }
}
