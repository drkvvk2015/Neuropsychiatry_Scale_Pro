import '../core/constants.dart';

/// Represents a single scale question/item.
class ScaleItem {
  final String key;
  final String question;
  final int minScore;
  final int maxScore;
  final List<String> labels;

  const ScaleItem({
    required this.key,
    required this.question,
    required this.minScore,
    required this.maxScore,
    required this.labels,
  });
}

/// Centralized scoring engine for all psychiatric scales.
class ScoringEngine {
  // ── BPRS (24-item, each 1-7) ────────────────────────────────────────────
  static List<ScaleItem> get bprsItems => [
        _item('somatic_concern', 'Somatic Concern', 7),
        _item('anxiety', 'Anxiety', 7),
        _item('emotional_withdrawal', 'Emotional Withdrawal', 7),
        _item('conceptual_disorganization', 'Conceptual Disorganization', 7),
        _item('guilt_feelings', 'Guilt Feelings', 7),
        _item('tension', 'Tension', 7),
        _item('mannerisms', 'Mannerisms & Posturing', 7),
        _item('grandiosity', 'Grandiosity', 7),
        _item('depressive_mood', 'Depressive Mood', 7),
        _item('hostility', 'Hostility', 7),
        _item('suspiciousness', 'Suspiciousness', 7),
        _item('hallucinatory_behavior', 'Hallucinatory Behavior', 7),
        _item('motor_retardation', 'Motor Retardation', 7),
        _item('uncooperativeness', 'Uncooperativeness', 7),
        _item('unusual_thought_content', 'Unusual Thought Content', 7),
        _item('blunted_affect', 'Blunted Affect', 7),
        _item('excitement', 'Excitement', 7),
        _item('disorientation', 'Disorientation', 7),
        _item('self_neglect', 'Self Neglect', 7),
        _item('elevated_mood', 'Elevated Mood', 7),
        _item('motor_hyperactivity', 'Motor Hyperactivity', 7),
        _item('speech_disorganization', 'Speech Disorganization', 7),
        _item('blunted_affect2', 'Emotional Blunting', 7),
        _item('conceptual_disorg2', 'Thought Process Disorder', 7),
      ];

  static String bprsSeverity(int score) {
    if (score < 31) return AppConstants.severityNormal;
    if (score < 41) return AppConstants.severityMild;
    if (score < 53) return AppConstants.severityModerate;
    if (score < 65) return AppConstants.severitySevere;
    return AppConstants.severityVerySevere;
  }

  // ── PHQ-9 (9 items, each 0-3) ───────────────────────────────────────────
  static List<ScaleItem> get phq9Items => [
        _phqItem('anhedonia', 'Little interest or pleasure in doing things'),
        _phqItem('depressed_mood', 'Feeling down, depressed, or hopeless'),
        _phqItem('sleep', 'Trouble falling/staying asleep, or sleeping too much'),
        _phqItem('fatigue', 'Feeling tired or having little energy'),
        _phqItem('appetite', 'Poor appetite or overeating'),
        _phqItem('self_worth', 'Feeling bad about yourself or that you are a failure'),
        _phqItem('concentration', 'Trouble concentrating on things'),
        _phqItem('psychomotor', 'Moving/speaking slowly or being fidgety/restless'),
        _phqItem(
            'suicidal', 'Thoughts that you would be better off dead or hurting yourself'),
      ];

  static String phq9Severity(int score) {
    if (score <= 4) return AppConstants.severityNormal;
    if (score <= 9) return AppConstants.severityMild;
    if (score <= 14) return AppConstants.severityModerate;
    if (score <= 19) return AppConstants.severitySevere;
    return AppConstants.severityVerySevere;
  }

  // ── GAD-7 (7 items, each 0-3) ───────────────────────────────────────────
  static List<ScaleItem> get gad7Items => [
        _phqItem('nervous', 'Feeling nervous, anxious, or on edge'),
        _phqItem('worry_control', 'Not being able to stop or control worrying'),
        _phqItem('worry_various', 'Worrying too much about different things'),
        _phqItem('relaxing', 'Trouble relaxing'),
        _phqItem('restless', 'Being so restless that it is hard to sit still'),
        _phqItem('irritable', 'Becoming easily annoyed or irritable'),
        _phqItem('afraid', 'Feeling afraid, as if something awful might happen'),
      ];

  static String gad7Severity(int score) {
    if (score <= 4) return AppConstants.severityNormal;
    if (score <= 9) return AppConstants.severityMild;
    if (score <= 14) return AppConstants.severityModerate;
    return AppConstants.severitySevere;
  }

  // ── HAM-D (17 items) ────────────────────────────────────────────────────
  static List<ScaleItem> get hamdItems => [
        _item('depressed_mood', 'Depressed Mood', 4),
        _item('guilt', 'Guilt', 4),
        _item('suicide', 'Suicide', 4),
        _item('insomnia_early', 'Insomnia (Early)', 2),
        _item('insomnia_middle', 'Insomnia (Middle)', 2),
        _item('insomnia_late', 'Insomnia (Late)', 2),
        _item('work_activities', 'Work & Activities', 4),
        _item('retardation', 'Psychomotor Retardation', 4),
        _item('agitation', 'Agitation', 4),
        _item('anxiety_psychic', 'Anxiety (Psychic)', 4),
        _item('anxiety_somatic', 'Anxiety (Somatic)', 4),
        _item('somatic_gi', 'Somatic GI Symptoms', 2),
        _item('somatic_general', 'Somatic General', 2),
        _item('genital', 'Genital Symptoms', 2),
        _item('hypochondriasis', 'Hypochondriasis', 4),
        _item('weight_loss', 'Weight Loss', 2),
        _item('insight', 'Insight', 2),
      ];

  static String hamdSeverity(int score) {
    if (score <= 7) return AppConstants.severityNormal;
    if (score <= 13) return AppConstants.severityMild;
    if (score <= 18) return AppConstants.severityModerate;
    if (score <= 22) return AppConstants.severitySevere;
    return AppConstants.severityVerySevere;
  }

  // ── YMRS (11 items) ─────────────────────────────────────────────────────
  static List<ScaleItem> get ymrsItems => [
        _item('elevated_mood', 'Elevated Mood', 4),
        _item('energy', 'Increased Motor Activity-Energy', 4),
        _item('sexual_interest', 'Sexual Interest', 4),
        _item('sleep', 'Sleep', 4),
        _item('irritability', 'Irritability', 8),
        _item('speech', 'Speech (Rate and Amount)', 8),
        _item('language_thought', 'Language-Thought Disorder', 8),
        _item('thought_content', 'Content', 8),
        _item('disruptive', 'Disruptive-Aggressive Behavior', 8),
        _item('appearance', 'Appearance', 4),
        _item('insight', 'Insight', 4),
      ];

  static String ymrsSeverity(int score) {
    if (score <= 12) return AppConstants.severityNormal;
    if (score <= 19) return AppConstants.severityMild;
    if (score <= 29) return AppConstants.severityModerate;
    return AppConstants.severitySevere;
  }

  // ── Y-BOCS (10 items, each 0-4) ─────────────────────────────────────────
  static const _ybocsLabels = ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'];

  static List<ScaleItem> get ybocsItems => [
        _ybocsItem('obs_time', 'Time occupied by obsessions'),
        _ybocsItem('obs_interference', 'Interference from obsessions'),
        _ybocsItem('obs_distress', 'Distress from obsessions'),
        _ybocsItem('obs_resistance', 'Resistance to obsessions'),
        _ybocsItem('obs_control', 'Control over obsessions'),
        _ybocsItem('comp_time', 'Time occupied by compulsions'),
        _ybocsItem('comp_interference', 'Interference from compulsions'),
        _ybocsItem('comp_distress', 'Distress from compulsions'),
        _ybocsItem('comp_resistance', 'Resistance to compulsions'),
        _ybocsItem('comp_control', 'Control over compulsions'),
      ];

  static String ybocsSeverity(int score) {
    if (score <= 7) return AppConstants.severityNormal;
    if (score <= 15) return AppConstants.severityMild;
    if (score <= 23) return AppConstants.severityModerate;
    if (score <= 31) return AppConstants.severitySevere;
    return AppConstants.severityVerySevere;
  }

  // ── MMSE (30 points) ────────────────────────────────────────────────────
  static List<ScaleItem> get mmseItems => [
        ScaleItem(
            key: 'orientation_time',
            question: 'Orientation to Time (year/season/date/day/month)',
            minScore: 0,
            maxScore: 5,
            labels: ['0', '1', '2', '3', '4', '5']),
        ScaleItem(
            key: 'orientation_place',
            question: 'Orientation to Place (state/county/town/hospital/floor)',
            minScore: 0,
            maxScore: 5,
            labels: ['0', '1', '2', '3', '4', '5']),
        ScaleItem(
            key: 'registration',
            question: 'Registration (3 objects)',
            minScore: 0,
            maxScore: 3,
            labels: ['0', '1', '2', '3']),
        ScaleItem(
            key: 'attention_calc',
            question: 'Attention & Calculation (Serial 7s or WORLD)',
            minScore: 0,
            maxScore: 5,
            labels: ['0', '1', '2', '3', '4', '5']),
        ScaleItem(
            key: 'recall',
            question: 'Recall (3 objects)',
            minScore: 0,
            maxScore: 3,
            labels: ['0', '1', '2', '3']),
        ScaleItem(
            key: 'naming',
            question: 'Language: Naming (watch, pencil)',
            minScore: 0,
            maxScore: 2,
            labels: ['0', '1', '2']),
        ScaleItem(
            key: 'repetition',
            question: 'Language: Repetition',
            minScore: 0,
            maxScore: 1,
            labels: ['0', '1']),
        ScaleItem(
            key: 'comprehension',
            question: 'Language: 3-Stage Command',
            minScore: 0,
            maxScore: 3,
            labels: ['0', '1', '2', '3']),
        ScaleItem(
            key: 'reading',
            question: 'Language: Reading',
            minScore: 0,
            maxScore: 1,
            labels: ['0', '1']),
        ScaleItem(
            key: 'writing',
            question: 'Language: Writing',
            minScore: 0,
            maxScore: 1,
            labels: ['0', '1']),
        ScaleItem(
            key: 'copying',
            question: 'Visuospatial: Copying',
            minScore: 0,
            maxScore: 1,
            labels: ['0', '1']),
      ];

  static String mmseSeverity(int score) {
    if (score >= 24) return AppConstants.severityNormal;
    if (score >= 18) return AppConstants.severityMild;
    if (score >= 10) return AppConstants.severityModerate;
    return AppConstants.severitySevere;
  }

  // ── C-SSRS (Columbia Suicide Severity Rating Scale) ─────────────────────
  static List<ScaleItem> get cssrsItems => [
        ScaleItem(
            key: 'wish_dead',
            question: 'Wish to be Dead',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'passive_si',
            question: 'Passive Suicidal Ideation',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'active_si_no_plan',
            question: 'Active Suicidal Ideation without Plan',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'active_si_plan',
            question: 'Active Suicidal Ideation with Plan',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'active_si_intent',
            question: 'Active Suicidal Ideation with Intent',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'preparatory_behavior',
            question: 'Preparatory Behavior',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'aborted_attempt',
            question: 'Aborted Attempt',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'interrupted_attempt',
            question: 'Interrupted Attempt',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'actual_attempt',
            question: 'Actual Suicide Attempt',
            minScore: 0,
            maxScore: 1,
            labels: ['No', 'Yes']),
        ScaleItem(
            key: 'lethality',
            question: 'Lethality of Attempt (0=No injury, 5=Death)',
            minScore: 0,
            maxScore: 5,
            labels: ['0', '1', '2', '3', '4', '5']),
      ];

  static String cssrsRisk(Map<String, int> scores) {
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

  // ── Helpers ─────────────────────────────────────────────────────────────
  static List<ScaleItem> getItems(String scaleName) {
    switch (scaleName) {
      case AppConstants.scaleBPRS:
        return bprsItems;
      case AppConstants.scalePHQ9:
        return phq9Items;
      case AppConstants.scaleGAD7:
        return gad7Items;
      case AppConstants.scaleHAMD:
        return hamdItems;
      case AppConstants.scaleYMRS:
        return ymrsItems;
      case AppConstants.scaleYBOCS:
        return ybocsItems;
      case AppConstants.scaleMMSE:
        return mmseItems;
      case AppConstants.scaleCSSRS:
        return cssrsItems;
      default:
        return [];
    }
  }

  static String getSeverity(String scaleName, int score,
      [Map<String, int>? itemScores]) {
    switch (scaleName) {
      case AppConstants.scaleBPRS:
        return bprsSeverity(score);
      case AppConstants.scalePHQ9:
        return phq9Severity(score);
      case AppConstants.scaleGAD7:
        return gad7Severity(score);
      case AppConstants.scaleHAMD:
        return hamdSeverity(score);
      case AppConstants.scaleYMRS:
        return ymrsSeverity(score);
      case AppConstants.scaleYBOCS:
        return ybocsSeverity(score);
      case AppConstants.scaleMMSE:
        return mmseSeverity(score);
      case AppConstants.scaleCSSRS:
        return cssrsRisk(itemScores ?? {});
      default:
        return AppConstants.severityNormal;
    }
  }

  static int getMaxScore(String scaleName) {
    final items = getItems(scaleName);
    return items.fold(0, (sum, item) => sum + item.maxScore);
  }

  static ScaleItem _item(String key, String question, int max) => ScaleItem(
        key: key,
        question: question,
        minScore: 1,
        maxScore: max,
        labels: List.generate(max, (i) => '${i + 1}'),
      );

  static ScaleItem _phqItem(String key, String question) => ScaleItem(
        key: key,
        question: question,
        minScore: 0,
        maxScore: 3,
        labels: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      );

  static ScaleItem _ybocsItem(String key, String question) => ScaleItem(
        key: key,
        question: question,
        minScore: 0,
        maxScore: 4,
        labels: _ybocsLabels,
      );
}
