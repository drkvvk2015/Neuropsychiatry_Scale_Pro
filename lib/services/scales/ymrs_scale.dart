import '../../core/constants.dart';
import 'scale_support.dart';

List<ScaleItem> get ymrsItems => [
      standardScaleItem('elevated_mood', 'Elevated Mood', 4),
      standardScaleItem('energy', 'Increased Motor Activity-Energy', 4),
      standardScaleItem('sexual_interest', 'Sexual Interest', 4),
      standardScaleItem('sleep', 'Sleep', 4),
      standardScaleItem('irritability', 'Irritability', 8),
      standardScaleItem('speech', 'Speech (Rate and Amount)', 8),
      standardScaleItem('language_thought', 'Language-Thought Disorder', 8),
      standardScaleItem('thought_content', 'Content', 8),
      standardScaleItem('disruptive', 'Disruptive-Aggressive Behavior', 8),
      standardScaleItem('appearance', 'Appearance', 4),
      standardScaleItem('insight', 'Insight', 4),
    ];

String ymrsSeverity(int score) {
  if (score <= 12) return AppConstants.severityNormal;
  if (score <= 19) return AppConstants.severityMild;
  if (score <= 29) return AppConstants.severityModerate;
  return AppConstants.severitySevere;
}
