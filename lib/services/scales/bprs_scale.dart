import '../../core/constants.dart';
import 'scale_support.dart';

List<ScaleItem> get bprsItems => [
      standardScaleItem('somatic_concern', 'Somatic Concern', 7),
      standardScaleItem('anxiety', 'Anxiety', 7),
      standardScaleItem('emotional_withdrawal', 'Emotional Withdrawal', 7),
      standardScaleItem('conceptual_disorganization', 'Conceptual Disorganization', 7),
      standardScaleItem('guilt_feelings', 'Guilt Feelings', 7),
      standardScaleItem('tension', 'Tension', 7),
      standardScaleItem('mannerisms', 'Mannerisms & Posturing', 7),
      standardScaleItem('grandiosity', 'Grandiosity', 7),
      standardScaleItem('depressive_mood', 'Depressive Mood', 7),
      standardScaleItem('hostility', 'Hostility', 7),
      standardScaleItem('suspiciousness', 'Suspiciousness', 7),
      standardScaleItem('hallucinatory_behavior', 'Hallucinatory Behavior', 7),
      standardScaleItem('motor_retardation', 'Motor Retardation', 7),
      standardScaleItem('uncooperativeness', 'Uncooperativeness', 7),
      standardScaleItem('unusual_thought_content', 'Unusual Thought Content', 7),
      standardScaleItem('blunted_affect', 'Blunted Affect', 7),
      standardScaleItem('excitement', 'Excitement', 7),
      standardScaleItem('disorientation', 'Disorientation', 7),
      standardScaleItem('self_neglect', 'Self Neglect', 7),
      standardScaleItem('elevated_mood', 'Elevated Mood', 7),
      standardScaleItem('motor_hyperactivity', 'Motor Hyperactivity', 7),
      standardScaleItem('speech_disorganization', 'Speech Disorganization', 7),
      standardScaleItem('blunted_affect2', 'Emotional Blunting', 7),
      standardScaleItem('conceptual_disorg2', 'Thought Process Disorder', 7),
    ];

String bprsSeverity(int score) {
  if (score < 31) return AppConstants.severityNormal;
  if (score < 41) return AppConstants.severityMild;
  if (score < 53) return AppConstants.severityModerate;
  if (score < 65) return AppConstants.severitySevere;
  return AppConstants.severityVerySevere;
}
