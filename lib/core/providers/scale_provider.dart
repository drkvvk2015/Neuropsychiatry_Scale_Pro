import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/scale_model.dart';
import '../services/scale_definitions.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class ScaleProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  ScaleType? _selectedScaleType;
  Map<String, int> _currentScores = {};
  Assessment? _currentAssessment;
  bool _isAssessing = false;
  bool _isICUMode = false;
  String? _aiSummary;
  bool _isLoading = false;
  String? _lastError;

  ScaleType? get selectedScaleType => _selectedScaleType;
  Map<String, int> get currentScores => _currentScores;
  Assessment? get currentAssessment => _currentAssessment;
  bool get isAssessing => _isAssessing;
  bool get isICUMode => _isICUMode;
  String? get aiSummary => _aiSummary;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  ScaleDefinition? get currentScaleDefinition {
    if (_selectedScaleType == null) return null;
    return ScaleDefinitions.allScales[_selectedScaleType];
  }

  double get currentTotalScore {
    return _currentScores.values.fold(0, (sum, score) => sum + score);
  }

  SeverityLevel? get currentSeverityLevel {
    if (_selectedScaleType == null) return null;
    final definition = currentScaleDefinition;
    if (definition == null) return null;
    return definition.getSeverityLevel(currentTotalScore);
  }

  RiskLevel get currentRiskLevel {
    return currentSeverityLevel?.riskLevel ?? RiskLevel.none;
  }

  void selectScale(ScaleType scaleType) {
    _selectedScaleType = scaleType;
    _currentScores = {};
    _currentAssessment = null;
    _aiSummary = null;
    notifyListeners();
  }

  void setItemScore(String itemId, int score) {
    _currentScores[itemId] = score;
    notifyListeners();
  }

  void clearScores() {
    _currentScores = {};
    _currentAssessment = null;
    _aiSummary = null;
    notifyListeners();
  }

  void toggleICUMode() {
    _isICUMode = !_isICUMode;
    notifyListeners();
  }

  void startAssessment() {
    _isAssessing = true;
    _currentScores = {};
    _currentAssessment = null;
    _aiSummary = null;
    notifyListeners();
  }

  void cancelAssessment() {
    _isAssessing = false;
    _currentScores = {};
    _currentAssessment = null;
    _aiSummary = null;
    notifyListeners();
  }

  Future<Assessment?> completeAssessment(String patientId) async {
    if (_selectedScaleType == null || currentSeverityLevel == null) {
      return null;
    }

    _lastError = null;

    final severity = currentSeverityLevel!;
    final risk = currentRiskLevel;

    // Check for suicide risk (especially for PHQ-9 item 9 and C-SSRS)
    bool hasSuicideRisk = false;
    List<String> alerts = [];

    if (_selectedScaleType == ScaleType.phq9) {
      final item9Score = _currentScores['phq9_9'] ?? 0;
      if (item9Score > 0) {
        hasSuicideRisk = true;
        alerts.add('Patient reports suicidal thoughts (PHQ-9 Item 9)');
      }
    }

    if (_selectedScaleType == ScaleType.cssrs) {
      final totalSuicideScore = currentTotalScore;
      if (totalSuicideScore >= 5) {
        hasSuicideRisk = true;
        alerts.add('High suicide risk detected - immediate evaluation needed');
      }
    }

    if (risk == RiskLevel.critical) {
      alerts.add('Critical severity level - immediate intervention recommended');
    }

    final assessment = Assessment(
      id: const Uuid().v4(),
      patientId: patientId,
      scaleType: _selectedScaleType!,
      itemScores: Map.from(_currentScores),
      totalScore: currentTotalScore,
      severityLevel: severity,
      riskLevel: risk,
      assessedAt: DateTime.now(),
      hasSuicideRisk: hasSuicideRisk,
      alerts: alerts,
    );

    try {
      await _databaseService.insertAssessment(assessment);
      _currentAssessment = assessment;
      _isAssessing = false;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to save assessment. Please try again.';
      debugPrint('Error saving assessment: $e');
      notifyListeners();
      return null;
    }

    return assessment;
  }

  Future<void> generateAISummary(Assessment assessment, String? diagnosis) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Generate a basic AI summary (in a real app, this would call the AI engine)
      final summary = _generateBasicSummary(assessment, diagnosis);
      _aiSummary = summary;
    } catch (e) {
      debugPrint('Error generating AI summary: $e');
      _aiSummary = 'Unable to generate AI summary at this time.';
    }

    _isLoading = false;
    notifyListeners();
  }

  String _generateBasicSummary(Assessment assessment, String? diagnosis) {
    final definition = ScaleDefinitions.allScales[assessment.scaleType];
    final severity = assessment.severityLevel;
    final risk = assessment.riskLevel;

    StringBuffer summary = StringBuffer();

    summary.writeln('**Clinical Summary**');
    summary.writeln();
    summary.writeln('**Scale:** ${definition?.name}');
    summary.writeln('**Total Score:** ${assessment.totalScore} / ${definition?.maxScore}');
    summary.writeln('**Severity:** ${severity.name}');
    summary.writeln('**Risk Level:** ${risk.name.toUpperCase()}');
    summary.writeln();

    if (diagnosis != null && diagnosis.isNotEmpty) {
      summary.writeln('**Diagnosis:** $diagnosis');
    }

    summary.writeln();
    summary.writeln('**Interpretation:**');
    summary.writeln(severity.description);
    summary.writeln();

    // Add scale-specific interpretations
    switch (assessment.scaleType) {
      case ScaleType.phq9:
        summary.writeln('**Depression Screening Results:**');
        final item9Score = assessment.itemScores['phq9_9'] ?? 0;
        if (item9Score > 0) {
          summary.writeln('⚠️ **ALERT:** Patient endorses suicidal ideation. Immediate risk assessment required.');
        }
        summary.writeln('Recommend ${severity.riskLevel == RiskLevel.none || severity.riskLevel == RiskLevel.mild ? 'monitoring and follow-up' : 'active treatment intervention'}.');
        break;

      case ScaleType.gad7:
        summary.writeln('**Anxiety Screening Results:**');
        summary.writeln('Recommend ${severity.riskLevel == RiskLevel.none || severity.riskLevel == RiskLevel.mild ? 'monitoring' : 'anxiety management intervention'}.');
        break;

      case ScaleType.bprs:
        summary.writeln('**Comprehensive Psychiatric Assessment:**');
        summary.writeln('Consider ${risk == RiskLevel.critical ? 'immediate psychiatric consultation' : 'ongoing psychiatric management'}.');
        break;

      case ScaleType.cssrs:
        if (assessment.hasSuicideRisk) {
          summary.writeln('🚨 **SUICIDE RISK ALERT**');
          summary.writeln('Immediate safety planning and risk mitigation required.');
          summary.writeln('Consider hospitalization if risk cannot be managed outpatient.');
        }
        break;

      case ScaleType.mmse:
        summary.writeln('**Cognitive Assessment:**');
        if (severity.riskLevel == RiskLevel.severe) {
          summary.writeln('Significant cognitive impairment detected. Consider neurology referral and further workup.');
        }
        break;

      default:
        summary.writeln('Review clinical findings and consider appropriate intervention based on severity.');
    }

    if (assessment.alerts.isNotEmpty) {
      summary.writeln();
      summary.writeln('**Alerts:**');
      for (final alert in assessment.alerts) {
        summary.writeln('• $alert');
      }
    }

    summary.writeln();
    summary.writeln('**Note:** This AI-generated summary is for clinical support only and should not replace professional judgment.');

    return summary.toString();
  }

  List<Assessment> getPatientHistory(String patientId, List<Assessment> allAssessments) {
    return allAssessments
        .where((a) => a.patientId == patientId)
        .toList()
      ..sort((a, b) => b.assessedAt.compareTo(a.assessedAt));
  }
}