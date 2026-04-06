import 'package:flutter_test/flutter_test.dart';

import 'package:neuroscale_pro/core/models/scale_model.dart';

void main() {
  test('Assessment.fromMap handles mixed persisted value types safely', () {
    final map = <String, dynamic>{
      'id': 'a1',
      'patientId': 'p1',
      'scaleType': 'phq9',
      'itemScores': {'phq9_1': 1, 'phq9_2': 2},
      'totalScore': 3,
      'severityLevel': 'Mild',
      'riskLevel': 'mild',
      'assessedAt': 'invalid-date',
      'notes': null,
      'aiSummary': null,
      'hasSuicideRisk': 1,
      'alerts': '["alert-1"]',
    };

    final assessment = Assessment.fromMap(map);

    expect(assessment.id, 'a1');
    expect(assessment.patientId, 'p1');
    expect(assessment.scaleType, ScaleType.phq9);
    expect(assessment.totalScore, 3.0);
    expect(assessment.itemScores['phq9_1'], 1);
    expect(assessment.itemScores['phq9_2'], 2);
    expect(assessment.hasSuicideRisk, isTrue);
    expect(assessment.alerts, contains('alert-1'));
    expect(assessment.assessedAt, isA<DateTime>());
  });
}
