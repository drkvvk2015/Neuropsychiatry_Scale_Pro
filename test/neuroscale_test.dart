import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_pro/services/scoring_engine.dart';
import 'package:neuroscale_pro/services/drug_engine.dart';
import 'package:neuroscale_pro/services/ai_engine.dart';
import 'package:neuroscale_pro/models/patient.dart';
import 'package:neuroscale_pro/models/scale_result.dart';
import 'package:neuroscale_pro/core/constants.dart';

void main() {
  // ── Scoring Engine Tests ─────────────────────────────────────────────────
  group('ScoringEngine', () {
    test('BPRS has 24 items', () {
      expect(ScoringEngine.bprsItems.length, 24);
    });

    test('PHQ-9 has 9 items', () {
      expect(ScoringEngine.phq9Items.length, 9);
    });

    test('GAD-7 has 7 items', () {
      expect(ScoringEngine.gad7Items.length, 7);
    });

    test('HAM-D has 17 items', () {
      expect(ScoringEngine.hamdItems.length, 17);
    });

    test('YMRS has 11 items', () {
      expect(ScoringEngine.ymrsItems.length, 11);
    });

    test('Y-BOCS has 10 items', () {
      expect(ScoringEngine.ybocsItems.length, 10);
    });

    test('MMSE has 11 items', () {
      expect(ScoringEngine.mmseItems.length, 11);
    });

    test('C-SSRS has 10 items', () {
      expect(ScoringEngine.cssrsItems.length, 10);
    });

    // PHQ-9 severity
    test('PHQ-9 score 0-4 → Normal', () {
      expect(ScoringEngine.phq9Severity(0), AppConstants.severityNormal);
      expect(ScoringEngine.phq9Severity(4), AppConstants.severityNormal);
    });

    test('PHQ-9 score 5-9 → Mild', () {
      expect(ScoringEngine.phq9Severity(5), AppConstants.severityMild);
      expect(ScoringEngine.phq9Severity(9), AppConstants.severityMild);
    });

    test('PHQ-9 score 10-14 → Moderate', () {
      expect(ScoringEngine.phq9Severity(10), AppConstants.severityModerate);
      expect(ScoringEngine.phq9Severity(14), AppConstants.severityModerate);
    });

    test('PHQ-9 score 15-19 → Severe', () {
      expect(ScoringEngine.phq9Severity(15), AppConstants.severitySevere);
      expect(ScoringEngine.phq9Severity(19), AppConstants.severitySevere);
    });

    test('PHQ-9 score 20-27 → Very Severe', () {
      expect(ScoringEngine.phq9Severity(20), AppConstants.severityVerySevere);
      expect(ScoringEngine.phq9Severity(27), AppConstants.severityVerySevere);
    });

    // GAD-7 severity
    test('GAD-7 score 0-4 → Normal', () {
      expect(ScoringEngine.gad7Severity(0), AppConstants.severityNormal);
    });

    test('GAD-7 score 10-14 → Moderate', () {
      expect(ScoringEngine.gad7Severity(12), AppConstants.severityModerate);
    });

    test('GAD-7 score 15+ → Severe', () {
      expect(ScoringEngine.gad7Severity(15), AppConstants.severitySevere);
    });

    // MMSE severity (higher = better)
    test('MMSE score >=24 → Normal', () {
      expect(ScoringEngine.mmseSeverity(28), AppConstants.severityNormal);
      expect(ScoringEngine.mmseSeverity(24), AppConstants.severityNormal);
    });

    test('MMSE score 18-23 → Mild', () {
      expect(ScoringEngine.mmseSeverity(20), AppConstants.severityMild);
    });

    test('MMSE score 10-17 → Moderate', () {
      expect(ScoringEngine.mmseSeverity(15), AppConstants.severityModerate);
    });

    test('MMSE score <10 → Severe', () {
      expect(ScoringEngine.mmseSeverity(5), AppConstants.severitySevere);
    });

    // C-SSRS risk
    test('C-SSRS no ideation → No Risk', () {
      final scores = <String, int>{};
      expect(ScoringEngine.cssrsRisk(scores), AppConstants.riskNone);
    });

    test('C-SSRS wish dead only → Low Risk', () {
      expect(
        ScoringEngine.cssrsRisk({'wish_dead': 1}),
        AppConstants.riskLow,
      );
    });

    test('C-SSRS actual attempt → Critical Risk', () {
      expect(
        ScoringEngine.cssrsRisk({'actual_attempt': 1}),
        AppConstants.riskCritical,
      );
    });

    test('C-SSRS intent + plan → High Risk', () {
      expect(
        ScoringEngine.cssrsRisk({'active_si_intent': 1}),
        AppConstants.riskHigh,
      );
    });

    // BPRS severity
    test('BPRS score < 31 → Normal', () {
      expect(ScoringEngine.bprsSeverity(24), AppConstants.severityNormal);
    });

    test('BPRS score 31-40 → Mild', () {
      expect(ScoringEngine.bprsSeverity(35), AppConstants.severityMild);
    });

    test('BPRS score 65+ → Very Severe', () {
      expect(ScoringEngine.bprsSeverity(80), AppConstants.severityVerySevere);
    });

    // HAMD severity
    test('HAMD score <=7 → Normal', () {
      expect(ScoringEngine.hamdSeverity(5), AppConstants.severityNormal);
    });

    test('HAMD score 8-13 → Mild', () {
      expect(ScoringEngine.hamdSeverity(10), AppConstants.severityMild);
    });

    test('HAMD score >22 → Very Severe', () {
      expect(ScoringEngine.hamdSeverity(25), AppConstants.severityVerySevere);
    });

    // getItems dispatch
    test('getItems returns correct items for each scale', () {
      for (final scale in [
        AppConstants.scaleBPRS,
        AppConstants.scalePHQ9,
        AppConstants.scaleGAD7,
        AppConstants.scaleHAMD,
        AppConstants.scaleYMRS,
        AppConstants.scaleYBOCS,
        AppConstants.scaleMMSE,
        AppConstants.scaleCSSRS,
      ]) {
        expect(ScoringEngine.getItems(scale).isNotEmpty, true,
            reason: '$scale should have items');
      }
    });

    // Max score calculation
    test('PHQ-9 max score is 27', () {
      expect(ScoringEngine.getMaxScore(AppConstants.scalePHQ9), 27);
    });

    test('GAD-7 max score is 21', () {
      expect(ScoringEngine.getMaxScore(AppConstants.scaleGAD7), 21);
    });

    test('Y-BOCS max score is 40', () {
      expect(ScoringEngine.getMaxScore(AppConstants.scaleYBOCS), 40);
    });
  });

  // ── Drug Engine Tests ───────────────────────────────────────────────────
  group('DrugEngine', () {
    test('Schizophrenia suggestion returns antipsychotics', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'Schizophrenia', severity: AppConstants.severityModerate);
      expect(s.firstLine.any((d) => d.toLowerCase().contains('risperidone')),
          true);
    });

    test('Depression suggestion returns SSRIs', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'Major Depressive Disorder',
          severity: AppConstants.severityModerate);
      expect(s.firstLine.any((d) => d.toLowerCase().contains('sertraline')),
          true);
    });

    test('Mild depression suggests psychotherapy first', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'Depression', severity: AppConstants.severityMild);
      expect(
          s.firstLine.any((d) => d.toLowerCase().contains('psychotherapy')),
          true);
    });

    test('Bipolar suggestion returns mood stabilizers', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'Bipolar Disorder', severity: AppConstants.severityModerate);
      expect(s.firstLine.any((d) => d.toLowerCase().contains('lithium')), true);
    });

    test('Anxiety suggestion returns SSRIs/SNRIs', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'Generalized Anxiety Disorder',
          severity: AppConstants.severityMild);
      expect(
          s.firstLine.any((d) => d.toLowerCase().contains('escitalopram')),
          true);
    });

    test('OCD suggestion returns SSRIs at higher doses', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'OCD', severity: AppConstants.severityModerate);
      expect(s.firstLine.any((d) => d.toLowerCase().contains('fluoxetine')),
          true);
    });

    test('Dementia suggestion returns cholinesterase inhibitors', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'Dementia', severity: AppConstants.severityMild);
      expect(s.firstLine.any((d) => d.toLowerCase().contains('donepezil')),
          true);
    });

    test('Unknown diagnosis returns generic message', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'Unknown condition', severity: AppConstants.severityMild);
      expect(s.firstLine.isNotEmpty, true);
    });

    test('Severe schizophrenia includes warning note', () {
      final s = DrugEngine.getSuggestions(
          diagnosis: 'Schizophrenia',
          severity: AppConstants.severitySevere);
      expect(s.notes.contains('⚠️'), true);
    });
  });

  // ── AI Engine Tests ─────────────────────────────────────────────────────
  group('AiEngine', () {
    final testPatient = Patient(
      name: 'Test Patient',
      age: 35,
      gender: 'Male',
      diagnosis: 'Schizophrenia',
      ward: 'Ward A',
    );

    test('Returns message when no results', () {
      final summary = AiEngine.generateClinicalSummary(
        patient: testPatient,
        results: [],
      );
      expect(summary.toLowerCase().contains('no scale'), true);
    });

    test('Summary contains patient name', () {
      final result = ScaleResult(
        patientId: testPatient.id,
        scaleName: AppConstants.scaleBPRS,
        totalScore: 55,
        severity: AppConstants.severitySevere,
        riskLevel: AppConstants.riskHigh,
        itemScores: {},
      );
      final summary = AiEngine.generateClinicalSummary(
        patient: testPatient,
        results: [result],
      );
      expect(summary.contains('Test Patient'), true);
    });

    test('Summary contains BPRS score', () {
      final result = ScaleResult(
        patientId: testPatient.id,
        scaleName: AppConstants.scaleBPRS,
        totalScore: 55,
        severity: AppConstants.severitySevere,
        riskLevel: AppConstants.riskHigh,
        itemScores: {},
      );
      final summary = AiEngine.generateClinicalSummary(
        patient: testPatient,
        results: [result],
      );
      expect(summary.contains('BPRS'), true);
      expect(summary.contains('55'), true);
    });

    test('Critical risk triggers urgent message in summary', () {
      final result = ScaleResult(
        patientId: testPatient.id,
        scaleName: AppConstants.scaleCSSRS,
        totalScore: 5,
        severity: AppConstants.riskCritical,
        riskLevel: AppConstants.riskCritical,
        itemScores: {'actual_attempt': 1},
      );
      final summary = AiEngine.generateClinicalSummary(
        patient: testPatient,
        results: [result],
      );
      expect(summary.contains('CRITICAL'), true);
    });

    test('Summary contains clinical note section', () {
      final result = ScaleResult(
        patientId: testPatient.id,
        scaleName: AppConstants.scalePHQ9,
        totalScore: 18,
        severity: AppConstants.severitySevere,
        riskLevel: AppConstants.riskModerate,
        itemScores: {},
      );
      final summary = AiEngine.generateClinicalSummary(
        patient: testPatient,
        results: [result],
      );
      expect(summary.contains('CLINICAL NOTE'), true);
    });
  });

  // ── Patient Model Tests ─────────────────────────────────────────────────
  group('Patient Model', () {
    test('Patient created with UUID', () {
      final p = Patient(name: 'John', age: 30, gender: 'Male');
      expect(p.id.isNotEmpty, true);
    });

    test('Patient serializes to/from map', () {
      final p = Patient(
        name: 'Jane Doe',
        age: 28,
        gender: 'Female',
        diagnosis: 'GAD',
        ward: 'OPD',
      );
      final map = p.toMap();
      final p2 = Patient.fromMap(map);
      expect(p2.name, p.name);
      expect(p2.age, p.age);
      expect(p2.gender, p.gender);
      expect(p2.diagnosis, p.diagnosis);
      expect(p2.ward, p.ward);
      expect(p2.id, p.id);
    });

    test('Patient copyWith preserves id', () {
      final p = Patient(name: 'John', age: 30, gender: 'Male');
      final p2 = p.copyWith(name: 'John Smith', age: 31);
      expect(p2.id, p.id);
      expect(p2.name, 'John Smith');
      expect(p2.age, 31);
    });
  });

  // ── ScaleResult Model Tests ─────────────────────────────────────────────
  group('ScaleResult Model', () {
    test('ScaleResult serializes to/from map', () {
      final r = ScaleResult(
        patientId: 'pid-123',
        scaleName: AppConstants.scalePHQ9,
        totalScore: 12,
        severity: AppConstants.severityModerate,
        riskLevel: AppConstants.riskLow,
        itemScores: {'anhedonia': 2, 'depressed_mood': 3},
      );
      final map = r.toMap();
      final r2 = ScaleResult.fromMap(map);
      expect(r2.patientId, r.patientId);
      expect(r2.scaleName, r.scaleName);
      expect(r2.totalScore, r.totalScore);
      expect(r2.severity, r.severity);
      expect(r2.itemScores['anhedonia'], 2);
      expect(r2.itemScores['depressed_mood'], 3);
    });

    test('ScaleResult has UUID id', () {
      final r = ScaleResult(
        patientId: 'pid',
        scaleName: 'PHQ-9',
        totalScore: 5,
        severity: 'Mild',
        riskLevel: 'Low Risk',
        itemScores: {},
      );
      expect(r.id.isNotEmpty, true);
    });
  });
}
