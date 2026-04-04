// This is a basic Flutter widget test for NeuroScale Pro.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:neuroscale_pro/main.dart';
import 'package:neuroscale_pro/core/providers/patient_provider.dart';

void main() {
  testWidgets('NeuroScale Pro app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(NeuroScalePro(patientProvider: PatientProvider()));

    // Verify that the app displays the dashboard title
    expect(find.text('NeuroScale Pro'), findsOneWidget);
    
    // Verify navigation bar is present
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Patients'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
