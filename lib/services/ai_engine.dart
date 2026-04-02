import '../models/patient.dart';
import '../models/scale_result.dart';
import '../core/constants.dart';

/// AI-powered clinical summary engine (runs offline, no network required).
/// Generates structured clinical summaries based on scale scores and patient data.
class AiEngine {
  /// Generate a comprehensive clinical summary for a patient.
  static String generateClinicalSummary({
    required Patient patient,
    required List<ScaleResult> results,
  }) {
    if (results.isEmpty) {
      return 'No scale assessments available. Please complete at least one psychiatric scale.';
    }

    final buffer = StringBuffer();

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('       CLINICAL SUMMARY REPORT');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Patient : ${patient.name}');
    buffer.writeln('Age/Sex : ${patient.age}Y / ${patient.gender}');
    buffer.writeln('Dx      : ${patient.diagnosis.isNotEmpty ? patient.diagnosis : "Pending"}');
    buffer.writeln('Ward    : ${patient.ward.isNotEmpty ? patient.ward : "OPD"}');
    buffer.writeln('Date    : ${_formatDate(DateTime.now())}');
    buffer.writeln('───────────────────────────────────────');

    // Severity summary
    buffer.writeln('\n📊 SCALE RESULTS:');
    String overallRisk = AppConstants.riskNone;
    final severities = <String>[];

    for (final result in results) {
      buffer.writeln(
          '  • ${result.scaleName}: ${result.totalScore} → ${result.severity}');
      severities.add(result.severity);
      if (_riskRank(result.riskLevel) > _riskRank(overallRisk)) {
        overallRisk = result.riskLevel;
      }
    }

    // Severity interpretation
    buffer.writeln('\n🔍 SEVERITY INTERPRETATION:');
    buffer.writeln(_interpretSeverities(severities, patient.diagnosis));

    // Risk assessment
    buffer.writeln('\n🚨 RISK ASSESSMENT:');
    buffer.writeln('  Overall Risk Level: $overallRisk');
    buffer.writeln(_getRiskNarrative(overallRisk, results));

    // Treatment plan
    buffer.writeln('\n💊 SUGGESTED MANAGEMENT:');
    buffer.writeln(_getTreatmentSuggestions(patient.diagnosis, severities, overallRisk));

    // Clinical note
    buffer.writeln('\n📋 CLINICAL NOTE:');
    buffer.writeln(_generateClinicalNote(patient, results, overallRisk));

    buffer.writeln('\n───────────────────────────────────────');
    buffer.writeln('⚠️  AI-generated summary — verify with clinical judgment');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  static String _interpretSeverities(List<String> severities, String diagnosis) {
    final hasSevere = severities.any((s) =>
        s == AppConstants.severitySevere ||
        s == AppConstants.severityVerySevere);
    final hasModerate = severities.any((s) => s == AppConstants.severityModerate);

    if (hasSevere) {
      return '  ⚠️  SEVERE presentation noted. Urgent intervention required.\n'
          '  Consider inpatient admission if patient safety is at risk.';
    }
    if (hasModerate) {
      return '  Moderate symptom burden. Structured outpatient/day-program\n'
          '  treatment recommended with close monitoring.';
    }
    return '  Mild to minimal symptom burden. Outpatient management\n'
        '  with regular follow-up appropriate.';
  }

  static String _getRiskNarrative(String risk, List<ScaleResult> results) {
    final cssrs =
        results.where((r) => r.scaleName == AppConstants.scaleCSSRS).firstOrNull;

    switch (risk) {
      case AppConstants.riskCritical:
        return '  🔴 CRITICAL RISK — IMMEDIATE ACTION REQUIRED\n'
            '  • Do NOT leave patient alone\n'
            '  • Initiate emergency psychiatric evaluation\n'
            '  • Consider involuntary admission if needed\n'
            '  • Remove access to means (medications, sharp objects)\n'
            '  • Alert treating team immediately';
      case AppConstants.riskHigh:
        return '  🟠 HIGH RISK — Urgent psychiatric review needed\n'
            '  • Frequent monitoring required\n'
            '  • Safety planning with patient and family\n'
            '  • Consider inpatient level of care\n'
            '  • Restrict access to means';
      case AppConstants.riskModerate:
        return '  🟡 MODERATE RISK — Enhanced monitoring\n'
            '  • Safety plan to be documented\n'
            '  • Involve family / support system\n'
            '  • Frequent outpatient follow-up';
      case AppConstants.riskLow:
        return '  🟢 LOW RISK — Routine monitoring\n'
            '  • Psychoeducation about warning signs\n'
            '  • Provide crisis line numbers\n'
            '  • Regular follow-up';
      default:
        if (cssrs != null) {
          return '  ✅ No suicidal ideation detected on C-SSRS\n'
              '  • Routine mental health monitoring';
        }
        return '  ℹ️  Suicide risk not formally assessed\n'
            '  • Consider administering C-SSRS';
    }
  }

  static String _getTreatmentSuggestions(
      String diagnosis, List<String> severities, String risk) {
    final diag = diagnosis.toLowerCase();
    final hasSevere = severities.any((s) =>
        s == AppConstants.severitySevere ||
        s == AppConstants.severityVerySevere);

    final suggestions = <String>[];

    // Pharmacotherapy
    suggestions.add('Pharmacotherapy:');
    if (diag.contains('schizophrenia') || diag.contains('psychosis')) {
      suggestions.add('  → Atypical antipsychotic (Risperidone/Olanzapine)');
      if (hasSevere) suggestions.add('  → Consider rapid tranquilization if agitated');
    } else if (diag.contains('bipolar') || diag.contains('mania')) {
      suggestions.add('  → Mood stabilizer (Lithium/Valproate)');
      suggestions.add('  → Atypical antipsychotic for acute mania');
    } else if (diag.contains('depression') || diag.contains('mdd')) {
      suggestions.add('  → SSRI (Sertraline/Escitalopram) for 6–8 weeks');
      if (hasSevere) suggestions.add('  → Consider augmentation strategy');
    } else if (diag.contains('anxiety') || diag.contains('gad')) {
      suggestions.add('  → SSRI/SNRI (first-line), avoid long-term BZD');
    } else {
      suggestions.add('  → Refer to drug suggestion engine for details');
    }

    // Psychotherapy
    suggestions.add('\nPsychotherapy:');
    if (diag.contains('depression') || diag.contains('anxiety') ||
        diag.contains('ptsd') || diag.contains('ocd')) {
      suggestions.add('  → Cognitive Behavioral Therapy (CBT)');
    } else if (diag.contains('schizophrenia')) {
      suggestions.add('  → Cognitive Remediation / Social Skills Training');
    } else {
      suggestions.add('  → Supportive psychotherapy');
    }

    // Monitoring
    suggestions.add('\nMonitoring:');
    suggestions.add('  → Repeat scale assessment in 2–4 weeks');
    suggestions.add('  → Metabolic panel, CBC, LFTs as indicated');
    if (risk != AppConstants.riskNone && risk != AppConstants.riskLow) {
      suggestions.add('  → Daily nursing check / ward observation');
    }

    return suggestions.map((s) => '  $s').join('\n');
  }

  static String _generateClinicalNote(
      Patient patient, List<ScaleResult> results, String risk) {
    final scaleText = results
        .map((r) => '${r.scaleName} = ${r.totalScore} (${r.severity})')
        .join(', ');

    return '  ${patient.name}, ${patient.age}Y ${patient.gender}, presented with '
        '${patient.diagnosis.isNotEmpty ? patient.diagnosis : "psychiatric symptoms"}. '
        'Standardized assessment reveals: $scaleText. '
        'Overall risk stratification: $risk. '
        '${risk == AppConstants.riskCritical || risk == AppConstants.riskHigh ? "Urgent intervention initiated. " : ""}'
        'Treatment plan discussed. '
        'Patient/family counseled. Follow-up arranged.';
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  static int _riskRank(String risk) {
    switch (risk) {
      case AppConstants.riskCritical:
        return 4;
      case AppConstants.riskHigh:
        return 3;
      case AppConstants.riskModerate:
        return 2;
      case AppConstants.riskLow:
        return 1;
      default:
        return 0;
    }
  }
}
