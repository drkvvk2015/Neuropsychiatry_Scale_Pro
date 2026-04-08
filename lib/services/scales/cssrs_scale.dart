import '../../core/constants.dart';
import 'scale_support.dart';

List<ScaleItem> get cssrsItems => const [
      ScaleItem(key: 'wish_dead', question: 'Wish to be Dead', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'passive_si', question: 'Passive Suicidal Ideation', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'active_si_no_plan', question: 'Active Suicidal Ideation without Plan', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'active_si_plan', question: 'Active Suicidal Ideation with Plan', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'active_si_intent', question: 'Active Suicidal Ideation with Intent', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'preparatory_behavior', question: 'Preparatory Behavior', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'aborted_attempt', question: 'Aborted Attempt', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'interrupted_attempt', question: 'Interrupted Attempt', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'actual_attempt', question: 'Actual Suicide Attempt', minScore: 0, maxScore: 1, labels: ['No', 'Yes']),
      ScaleItem(key: 'lethality', question: 'Lethality of Attempt (0=No injury, 5=Death)', minScore: 0, maxScore: 5, labels: ['0', '1', '2', '3', '4', '5']),
    ];

String cssrsRisk(Map<String, int> scores) {
  final attempt = scores['actual_attempt'] ?? 0;
  final intentPlan = scores['active_si_intent'] ?? 0;
  final planYes = scores['active_si_plan'] ?? 0;
  final preparatory = scores['preparatory_behavior'] ?? 0;
  final lethality = scores['lethality'] ?? 0;

  if (attempt > 0 || lethality > 0) return AppConstants.riskCritical;
  if (intentPlan > 0 || preparatory > 0) return AppConstants.riskHigh;
  if (planYes > 0) return AppConstants.riskModerate;
  if ((scores['active_si_no_plan'] ?? 0) > 0) return AppConstants.riskLow;
  if ((scores['passive_si'] ?? 0) > 0 || (scores['wish_dead'] ?? 0) > 0) {
    return AppConstants.riskLow;
  }
  return AppConstants.riskNone;
}
