import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:neuroscale_pro/core/models/patient_model.dart';
import 'package:neuroscale_pro/core/models/scale_model.dart';
import 'package:neuroscale_pro/core/providers/patient_provider.dart';
import 'package:neuroscale_pro/core/providers/scale_provider.dart';
import 'package:neuroscale_pro/screens/assessment_screen.dart';

void main() {
  testWidgets('ICU BPRS view does not expose score 0 option', (tester) async {
    final scaleProvider = ScaleProvider();
    scaleProvider.selectScale(ScaleType.bprs);
    scaleProvider.startAssessment();

    final patient = Patient(
      id: 'p1',
      name: 'Test Patient',
      age: 30,
      gender: 'Male',
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ScaleProvider>.value(value: scaleProvider),
          ChangeNotifierProvider<PatientProvider>(
            create: (_) => PatientProvider(),
          ),
        ],
        child: MaterialApp(
          home: AssessmentScreen(patient: patient, isICUMode: true),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Score: 0'), findsNothing);
    expect(find.text('0'), findsNothing);
  });
}
