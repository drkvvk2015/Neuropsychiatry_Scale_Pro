import 'package:flutter/foundation.dart';

import '../models/scale_model.dart';
import '../services/ai_engine.dart';
import '../theme/app_theme.dart';

class AIProvider with ChangeNotifier {
  final AIEngine _aiEngine = AIEngine();
  
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _lastError;
  String? _modelPath;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  String? get modelPath => _modelPath;

  Future<void> initialize({String? modelPath}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _aiEngine.initialize(modelPath: modelPath);
      _isInitialized = true;
      _modelPath = modelPath;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('AI Engine initialization error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> generateClinicalSummary({
    required Assessment assessment,
    required String patientName,
    required int patientAge,
    required String patientGender,
    String? diagnosis,
  }) async {
    if (!_isInitialized) {
      return _generateFallbackSummary(assessment, patientName, patientAge, patientGender, diagnosis);
    }

    _isLoading = true;
    notifyListeners();

    try {
      final prompt = _buildClinicalPrompt(
        assessment: assessment,
        patientName: patientName,
        patientAge: patientAge,
        patientGender: patientGender,
        diagnosis: diagnosis,
      );

      final response = await _aiEngine.generateText(
        prompt: prompt,
        maxTokens: 500,
        temperature: 0.7,
      );

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      debugPrint('AI generation error: $e');
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return _generateFallbackSummary(assessment, patientName, patientAge, patientGender, diagnosis);
    }
  }

  Future<String> generateDrugSuggestions({
    required String diagnosis,
    required double severity,
    required int patientAge,
    String? allergies,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Generate guideline-based drug suggestions
      final suggestions = _generateGuidelineBasedSuggestions(
        diagnosis: diagnosis,
        severity: severity,
        patientAge: patientAge,
        allergies: allergies,
      );

      _isLoading = false;
      notifyListeners();
      return suggestions;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Unable to generate drug suggestions at this time.';
    }
  }

  String _generateGuidelineBasedSuggestions({
    required String diagnosis,
    required double severity,
    required int patientAge,
    String? allergies,
  }) {
    StringBuffer suggestions = StringBuffer();
    
    suggestions.writeln('**Pharmacological Recommendations**');
    suggestions.writeln();
    suggestions.writeln('**Diagnosis:** $diagnosis');
    suggestions.writeln('**Severity:** $severity');
    suggestions.writeln('**Patient Age:** $patientAge years');
    if (allergies != null && allergies.isNotEmpty) {
      suggestions.writeln('**Allergies:** $allergies - AVOID related medications');
    }
    suggestions.writeln();

    final lowerDiagnosis = diagnosis.toLowerCase();

    // Depression
    if (lowerDiagnosis.contains('depression') || lowerDiagnosis.contains('depressive')) {
      suggestions.writeln('**First-line Options:**');
      suggestions.writeln('• SSRIs: Sertraline (50-200mg), Escitalopram (10-20mg), Fluoxetine (20-60mg)');
      suggestions.writeln('• SNRIs: Venlafaxine (75-225mg), Duloxetine (60-120mg)');
      suggestions.writeln();
      if (severity >= 20) {
        suggestions.writeln('**For Severe Depression:**');
        suggestions.writeln('• Consider combination therapy (SSRI + Bupropion or Mirtazapine)');
        suggestions.writeln('• Evaluate for ECT if treatment-resistant');
      }
    }

    // Anxiety
    if (lowerDiagnosis.contains('anxiety') || lowerDiagnosis.contains('gad') || lowerDiagnosis.contains('panic')) {
      suggestions.writeln('**First-line Options:**');
      suggestions.writeln('• SSRIs: Escitalopram (10-20mg), Sertraline (50-200mg), Paroxetine (20-60mg)');
      suggestions.writeln('• SNRIs: Venlafaxine XR (75-225mg), Duloxetine (60-120mg)');
      suggestions.writeln();
      suggestions.writeln('**Adjunct Options:**');
      suggestions.writeln('• Buspirone (15-60mg divided)');
      suggestions.writeln('• Pregabalin (150-600mg divided)');
      suggestions.writeln('• Short-term benzodiazepines (use cautiously)');
    }

    // Bipolar
    if (lowerDiagnosis.contains('bipolar') || lowerDiagnosis.contains('mania')) {
      suggestions.writeln('**Mood Stabilizers:**');
      suggestions.writeln('• Lithium (900-1800mg, monitor levels)');
      suggestions.writeln('• Valproate (750-2000mg, monitor LFTs)');
      suggestions.writeln('• Lamotrigine (titrate slowly to 200mg)');
      suggestions.writeln();
      suggestions.writeln('**Atypical Antipsychotics:**');
      suggestions.writeln('• Quetiapine (300-800mg)');
      suggestions.writeln('• Olanzapine (10-20mg)');
      suggestions.writeln('• Aripiprazole (10-30mg)');
    }

    // Schizophrenia/Psychosis
    if (lowerDiagnosis.contains('schizophrenia') || lowerDiagnosis.contains('psychosis') || lowerDiagnosis.contains('psychotic')) {
      suggestions.writeln('**First-line Atypical Antipsychotics:**');
      suggestions.writeln('• Risperidone (2-6mg)');
      suggestions.writeln('• Olanzapine (10-20mg)');
      suggestions.writeln('• Aripiprazole (10-30mg)');
      suggestions.writeln('• Quetiapine (400-800mg)');
      suggestions.writeln();
      suggestions.writeln('**If Treatment-Resistant:**');
      suggestions.writeln('• Clozapine (requires monitoring)');
      suggestions.writeln('• Consider LAI formulations for adherence issues');
    }

    // OCD
    if (lowerDiagnosis.contains('ocd') || lowerDiagnosis.contains('obsessive')) {
      suggestions.writeln('**First-line Options:**');
      suggestions.writeln('• SSRIs (often at higher doses):');
      suggestions.writeln('  - Fluoxetine (40-80mg)');
      suggestions.writeln('  - Sertraline (100-200mg)');
      suggestions.writeln('  - Fluvoxamine (100-300mg)');
      suggestions.writeln();
      suggestions.writeln('**Augmentation:**');
      suggestions.writeln('• Low-dose antipsychotic (Risperidone 0.5-2mg)');
    }

    suggestions.writeln();
    suggestions.writeln('**Important Notes:**');
    suggestions.writeln('• Start low and titrate slowly, especially in elderly');
    suggestions.writeln('• Monitor for side effects and drug interactions');
    suggestions.writeln('• Consider patient preferences and previous treatment response');
    suggestions.writeln('• Combine with psychotherapy when appropriate');
    suggestions.writeln();
    suggestions.writeln('⚠️ **Disclaimer:** These are general guidelines. Always use clinical judgment and consider individual patient factors.');

    return suggestions.toString();
  }

  String _buildClinicalPrompt({
    required Assessment assessment,
    required String patientName,
    required int patientAge,
    required String patientGender,
    String? diagnosis,
  }) {
    final scaleName = assessment.scaleType.name.toUpperCase();
    
    return '''You are an experienced psychiatrist providing clinical consultation.

PATIENT INFORMATION:
- Name: $patientName
- Age: $patientAge
- Gender: $patientGender
${diagnosis != null ? '- Diagnosis: $diagnosis' : ''}

ASSESSMENT RESULTS:
- Scale: $scaleName
- Total Score: ${assessment.totalScore}
- Severity: ${assessment.severityLevel.name}
- Risk Level: ${assessment.riskLevel.name}

Please provide:
1. Clinical interpretation of the findings
2. Risk assessment and safety considerations
3. Treatment recommendations (pharmacological and non-pharmacological)
4. Follow-up plan

Be concise but thorough. Focus on actionable clinical guidance.''';
  }

  String _generateFallbackSummary(
    Assessment assessment,
    String patientName,
    int patientAge,
    String patientGender,
    String? diagnosis,
  ) {
    return '''**Clinical Summary**

**Patient:** $patientName ($patientAge-year-old $patientGender)
${diagnosis != null ? '**Diagnosis:** $diagnosis\n' : ''}
**Scale:** ${assessment.scaleType.name.toUpperCase()}
**Score:** ${assessment.totalScore}
**Severity:** ${assessment.severityLevel.name}
**Risk Level:** ${assessment.riskLevel.name.toUpperCase()}

**Clinical Interpretation:**
${assessment.severityLevel.description}

**Recommendations:**
${assessment.riskLevel == RiskLevel.critical || assessment.riskLevel == RiskLevel.severe 
    ? '• Urgent psychiatric evaluation recommended\n• Consider safety planning\n• May need intensive treatment or hospitalization' 
    : '• Continue current treatment plan\n• Regular follow-up recommended\n• Monitor for symptom changes'}

*Note: AI assistant is currently offline. This is a basic summary.*''';
  }

  void reset() {
    _isInitialized = false;
    _isLoading = false;
    _lastError = null;
    _modelPath = null;
    notifyListeners();
  }
}