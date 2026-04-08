import '../../core/constants.dart';
import 'scale_support.dart';

List<ScaleItem> get mmseItems => const [
      ScaleItem(key: 'orientation_time', question: 'Orientation to Time (year/season/date/day/month)', minScore: 0, maxScore: 5, labels: ['0', '1', '2', '3', '4', '5']),
      ScaleItem(key: 'orientation_place', question: 'Orientation to Place (state/county/town/hospital/floor)', minScore: 0, maxScore: 5, labels: ['0', '1', '2', '3', '4', '5']),
      ScaleItem(key: 'registration', question: 'Registration (3 objects)', minScore: 0, maxScore: 3, labels: ['0', '1', '2', '3']),
      ScaleItem(key: 'attention_calc', question: 'Attention & Calculation (Serial 7s or WORLD)', minScore: 0, maxScore: 5, labels: ['0', '1', '2', '3', '4', '5']),
      ScaleItem(key: 'recall', question: 'Recall (3 objects)', minScore: 0, maxScore: 3, labels: ['0', '1', '2', '3']),
      ScaleItem(key: 'naming', question: 'Language: Naming (watch, pencil)', minScore: 0, maxScore: 2, labels: ['0', '1', '2']),
      ScaleItem(key: 'repetition', question: 'Language: Repetition', minScore: 0, maxScore: 1, labels: ['0', '1']),
      ScaleItem(key: 'comprehension', question: 'Language: 3-Stage Command', minScore: 0, maxScore: 3, labels: ['0', '1', '2', '3']),
      ScaleItem(key: 'reading', question: 'Language: Reading', minScore: 0, maxScore: 1, labels: ['0', '1']),
      ScaleItem(key: 'writing', question: 'Language: Writing', minScore: 0, maxScore: 1, labels: ['0', '1']),
      ScaleItem(key: 'copying', question: 'Visuospatial: Copying', minScore: 0, maxScore: 1, labels: ['0', '1']),
    ];

String mmseSeverity(int score) {
  if (score >= 24) return AppConstants.severityNormal;
  if (score >= 18) return AppConstants.severityMild;
  if (score >= 10) return AppConstants.severityModerate;
  return AppConstants.severitySevere;
}
