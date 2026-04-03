import '../models/scale_model.dart';
import '../theme/app_theme.dart';

class ScaleDefinitions {
  static Map<ScaleType, ScaleDefinition> get allScales => {
        ScaleType.phq9: phq9,
        ScaleType.gad7: gad7,
        ScaleType.bprs: bprs,
        ScaleType.hamd: hamd,
        ScaleType.ymrs: ymrs,
        ScaleType.ybocs: ybocs,
        ScaleType.mmse: mmse,
        ScaleType.cssrs: cssrs,
      };

  // PHQ-9: Patient Health Questionnaire-9
  static const ScaleDefinition phq9 = ScaleDefinition(
    type: ScaleType.phq9,
    name: 'PHQ-9',
    description: 'Patient Health Questionnaire-9 for depression screening',
    maxScore: 27,
    items: [
      ScaleItem(
        id: 'phq9_1',
        question: 'Little interest or pleasure in doing things',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'phq9_2',
        question: 'Feeling down, depressed, or hopeless',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'phq9_3',
        question: 'Trouble falling or staying asleep, or sleeping too much',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'phq9_4',
        question: 'Feeling tired or having little energy',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'phq9_5',
        question: 'Poor appetite or overeating',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'phq9_6',
        question: 'Feeling bad about yourself - or that you are a failure or have let yourself or your family down',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'phq9_7',
        question: 'Trouble concentrating on things, such as reading the newspaper or watching television',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'phq9_8',
        question: 'Moving or speaking so slowly that other people could have noticed. Or the opposite - being so fidgety or restless that you have been moving around a lot more than usual',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'phq9_9',
        question: 'Thoughts that you would be better off dead, or of hurting yourself in some way',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
    ],
    severityLevels: [
      SeverityLevel(name: 'None/Minimal', minScore: 0, maxScore: 4, description: 'Minimal or no depression symptoms', riskLevel: RiskLevel.none),
      SeverityLevel(name: 'Mild', minScore: 5, maxScore: 9, description: 'Mild depression, watchful waiting may be appropriate', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Moderate', minScore: 10, maxScore: 14, description: 'Moderate depression, treatment plan recommended', riskLevel: RiskLevel.moderate),
      SeverityLevel(name: 'Moderately Severe', minScore: 15, maxScore: 19, description: 'Moderately severe depression, active treatment needed', riskLevel: RiskLevel.severe),
      SeverityLevel(name: 'Severe', minScore: 20, maxScore: 27, description: 'Severe depression, immediate intervention required', riskLevel: RiskLevel.critical),
    ],
  );

  // GAD-7: Generalized Anxiety Disorder-7
  static const ScaleDefinition gad7 = ScaleDefinition(
    type: ScaleType.gad7,
    name: 'GAD-7',
    description: 'Generalized Anxiety Disorder-7 for anxiety screening',
    maxScore: 21,
    items: [
      ScaleItem(
        id: 'gad7_1',
        question: 'Feeling nervous, anxious, or on edge',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'gad7_2',
        question: 'Not being able to stop or control worrying',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'gad7_3',
        question: 'Worrying too much about different things',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'gad7_4',
        question: 'Trouble relaxing',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'gad7_5',
        question: 'Being so restless that it\'s hard to sit still',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'gad7_6',
        question: 'Becoming easily annoyed or irritable',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
      ScaleItem(
        id: 'gad7_7',
        question: 'Feeling afraid as if something awful might happen',
        maxScore: 3,
        options: [
          ScaleOption(value: 0, label: 'Not at all'),
          ScaleOption(value: 1, label: 'Several days'),
          ScaleOption(value: 2, label: 'More than half the days'),
          ScaleOption(value: 3, label: 'Nearly every day'),
        ],
      ),
    ],
    severityLevels: [
      SeverityLevel(name: 'Minimal', minScore: 0, maxScore: 4, description: 'Minimal anxiety symptoms', riskLevel: RiskLevel.none),
      SeverityLevel(name: 'Mild', minScore: 5, maxScore: 9, description: 'Mild anxiety', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Moderate', minScore: 10, maxScore: 14, description: 'Moderate anxiety', riskLevel: RiskLevel.moderate),
      SeverityLevel(name: 'Severe', minScore: 15, maxScore: 21, description: 'Severe anxiety', riskLevel: RiskLevel.severe),
    ],
  );

  // BPRS: Brief Psychiatric Rating Scale (24 items)
  static ScaleDefinition get bprs => ScaleDefinition(
    type: ScaleType.bprs,
    name: 'BPRS',
    description: 'Brief Psychiatric Rating Scale - 24 items for comprehensive psychiatric assessment',
    maxScore: 168,
    items: List.generate(24, (index) {
      const items = [
        'Somatic concern', 'Anxiety', 'Emotional withdrawal', 'Conceptual disorganization',
        'Guilt feelings', 'Tension', 'Mannerisms and posturing', 'Grandiosity',
        'Depressive mood', 'Hostility', 'Suspiciousness', 'Hallucinatory behavior',
        'Motor retardation', 'Uncooperativeness', 'Unusual thought content', 'Blunted affect',
        'Excitement', 'Distractibility', 'Orientation', 'Bizarre behavior',
        'Self-neglect', 'Preoccupation', 'Active social avoidance', 'Motor hyperactivity'
      ];
      return ScaleItem(
        id: 'bprs_${index + 1}',
        question: items[index],
        maxScore: 7,
        options: [
          ScaleOption(value: 1, label: 'Not present'),
          ScaleOption(value: 2, label: 'Very mild'),
          ScaleOption(value: 3, label: 'Mild'),
          ScaleOption(value: 4, label: 'Moderate'),
          ScaleOption(value: 5, label: 'Moderately severe'),
          ScaleOption(value: 6, label: 'Severe'),
          ScaleOption(value: 7, label: 'Extremely severe'),
        ],
      );
    }),
    severityLevels: [
      SeverityLevel(name: 'Not Ill', minScore: 24, maxScore: 35, description: 'No significant psychiatric symptoms', riskLevel: RiskLevel.none),
      SeverityLevel(name: 'Borderline Ill', minScore: 36, maxScore: 53, description: 'Borderline psychiatric symptoms', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Mildly Ill', minScore: 54, maxScore: 71, description: 'Mild psychiatric symptoms', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Moderately Ill', minScore: 72, maxScore: 89, description: 'Moderate psychiatric symptoms', riskLevel: RiskLevel.moderate),
      SeverityLevel(name: 'Markedly Ill', minScore: 90, maxScore: 107, description: 'Marked psychiatric symptoms', riskLevel: RiskLevel.severe),
      SeverityLevel(name: 'Severely Ill', minScore: 108, maxScore: 125, description: 'Severe psychiatric symptoms', riskLevel: RiskLevel.severe),
      SeverityLevel(name: 'Extremely Ill', minScore: 126, maxScore: 168, description: 'Extremely severe psychiatric symptoms', riskLevel: RiskLevel.critical),
    ],
  );

  // HAM-D: Hamilton Depression Rating Scale
  static ScaleDefinition get hamd => ScaleDefinition(
    type: ScaleType.hamd,
    name: 'HAM-D',
    description: 'Hamilton Depression Rating Scale for assessing depression severity',
    maxScore: 52,
    items: List.generate(17, (index) {
      const items = [
        'Depressed mood', 'Feelings of guilt', 'Suicide', 'Insomnia early',
        'Insomnia middle', 'Insomnia late', 'Work and activities', 'Retardation',
        'Agitation', 'Anxiety psychic', 'Anxiety somatic', 'Somatic symptoms GI',
        'Somatic symptoms general', 'Genital symptoms', 'Hypochondriasis', 'Loss of weight',
        'Insight'
      ];
      final maxScores = [2, 2, 4, 2, 2, 2, 4, 4, 2, 4, 4, 2, 2, 2, 2, 2, 2];
      final options = List.generate(maxScores[index] + 1, (i) => ScaleOption(value: i, label: '$i'));
      return ScaleItem(
        id: 'hamd_${index + 1}',
        question: items[index],
        maxScore: maxScores[index],
        options: options,
      );
    }),
    severityLevels: [
      SeverityLevel(name: 'None', minScore: 0, maxScore: 7, description: 'No depression', riskLevel: RiskLevel.none),
      SeverityLevel(name: 'Mild', minScore: 8, maxScore: 13, description: 'Mild depression', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Moderate', minScore: 14, maxScore: 18, description: 'Moderate depression', riskLevel: RiskLevel.moderate),
      SeverityLevel(name: 'Severe', minScore: 19, maxScore: 22, description: 'Severe depression', riskLevel: RiskLevel.severe),
      SeverityLevel(name: 'Very Severe', minScore: 23, maxScore: 52, description: 'Very severe depression', riskLevel: RiskLevel.critical),
    ],
  );

  // YMRS: Young Mania Rating Scale
  static ScaleDefinition get ymrs => ScaleDefinition(
    type: ScaleType.ymrs,
    name: 'YMRS',
    description: 'Young Mania Rating Scale for assessing manic symptoms',
    maxScore: 60,
    items: List.generate(11, (index) {
      const items = [
        'Elevated mood', 'Increased motor activity-energy', 'Sexual interest', 'Sleep',
        'Irritability', 'Speech (rate and amount)', 'Language-thought disorder', 'Content',
        'Disruptive-aggressive behavior', 'Appearance', 'Insight'
      ];
      final maxScores = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 8];
      final options = List.generate(maxScores[index] + 1, (i) => ScaleOption(value: i, label: '$i'));
      return ScaleItem(
        id: 'ymrs_${index + 1}',
        question: items[index],
        maxScore: maxScores[index],
        options: options,
      );
    }),
    severityLevels: [
      SeverityLevel(name: 'Remission', minScore: 0, maxScore: 6, description: 'Mania in remission', riskLevel: RiskLevel.none),
      SeverityLevel(name: 'Mild', minScore: 7, maxScore: 12, description: 'Mild mania', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Moderate', minScore: 13, maxScore: 19, description: 'Moderate mania', riskLevel: RiskLevel.moderate),
      SeverityLevel(name: 'Severe', minScore: 20, maxScore: 25, description: 'Severe mania', riskLevel: RiskLevel.severe),
      SeverityLevel(name: 'Very Severe', minScore: 26, maxScore: 60, description: 'Very severe mania', riskLevel: RiskLevel.critical),
    ],
  );

  // Y-BOCS: Yale-Brown Obsessive Compulsive Scale
  static ScaleDefinition get ybocs => ScaleDefinition(
    type: ScaleType.ybocs,
    name: 'Y-BOCS',
    description: 'Yale-Brown Obsessive Compulsive Scale for assessing OCD severity',
    maxScore: 40,
    items: List.generate(10, (index) {
      const items = [
        'Time spent on obsessions', 'Interference from obsessions', 'Distress from obsessions',
        'Resistance to obsessions', 'Control over obsessions', 'Time spent on compulsions',
        'Interference from compulsions', 'Distress from compulsions', 'Resistance to compulsions',
        'Control over compulsions'
      ];
      final options = [
        ScaleOption(value: 0, label: 'None'),
        ScaleOption(value: 1, label: 'Mild'),
        ScaleOption(value: 2, label: 'Moderate'),
        ScaleOption(value: 3, label: 'Severe'),
        ScaleOption(value: 4, label: 'Extreme'),
      ];
      return ScaleItem(
        id: 'ybocs_${index + 1}',
        question: items[index],
        maxScore: 4,
        options: options,
      );
    }),
    severityLevels: [
      SeverityLevel(name: 'Subclinical', minScore: 0, maxScore: 7, description: 'Subclinical OCD symptoms', riskLevel: RiskLevel.none),
      SeverityLevel(name: 'Mild', minScore: 8, maxScore: 15, description: 'Mild OCD', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Moderate', minScore: 16, maxScore: 23, description: 'Moderate OCD', riskLevel: RiskLevel.moderate),
      SeverityLevel(name: 'Severe', minScore: 24, maxScore: 31, description: 'Severe OCD', riskLevel: RiskLevel.severe),
      SeverityLevel(name: 'Extreme', minScore: 32, maxScore: 40, description: 'Extreme OCD', riskLevel: RiskLevel.critical),
    ],
  );

  // MMSE: Mini-Mental State Examination
  static ScaleDefinition get mmse => ScaleDefinition(
    type: ScaleType.mmse,
    name: 'MMSE',
    description: 'Mini-Mental State Examination for cognitive impairment screening',
    maxScore: 30,
    items: [
      ScaleItem(id: 'mmse_1', question: 'Orientation to time (5 points)', maxScore: 5, options: [
        ScaleOption(value: 0, label: '0/5'), ScaleOption(value: 1, label: '1/5'),
        ScaleOption(value: 2, label: '2/5'), ScaleOption(value: 3, label: '3/5'),
        ScaleOption(value: 4, label: '4/5'), ScaleOption(value: 5, label: '5/5'),
      ]),
      ScaleItem(id: 'mmse_2', question: 'Orientation to place (5 points)', maxScore: 5, options: [
        ScaleOption(value: 0, label: '0/5'), ScaleOption(value: 1, label: '1/5'),
        ScaleOption(value: 2, label: '2/5'), ScaleOption(value: 3, label: '3/5'),
        ScaleOption(value: 4, label: '4/5'), ScaleOption(value: 5, label: '5/5'),
      ]),
      ScaleItem(id: 'mmse_3', question: 'Registration (3 points)', maxScore: 3, options: [
        ScaleOption(value: 0, label: '0/3'), ScaleOption(value: 1, label: '1/3'),
        ScaleOption(value: 2, label: '2/3'), ScaleOption(value: 3, label: '3/3'),
      ]),
      ScaleItem(id: 'mmse_4', question: 'Attention and calculation (5 points)', maxScore: 5, options: [
        ScaleOption(value: 0, label: '0/5'), ScaleOption(value: 1, label: '1/5'),
        ScaleOption(value: 2, label: '2/5'), ScaleOption(value: 3, label: '3/5'),
        ScaleOption(value: 4, label: '4/5'), ScaleOption(value: 5, label: '5/5'),
      ]),
      ScaleItem(id: 'mmse_5', question: 'Recall (3 points)', maxScore: 3, options: [
        ScaleOption(value: 0, label: '0/3'), ScaleOption(value: 1, label: '1/3'),
        ScaleOption(value: 2, label: '2/3'), ScaleOption(value: 3, label: '3/3'),
      ]),
      ScaleItem(id: 'mmse_6', question: 'Language (2 points)', maxScore: 2, options: [
        ScaleOption(value: 0, label: '0/2'), ScaleOption(value: 1, label: '1/2'),
        ScaleOption(value: 2, label: '2/2'),
      ]),
      ScaleItem(id: 'mmse_7', question: 'Naming (2 points)', maxScore: 2, options: [
        ScaleOption(value: 0, label: '0/2'), ScaleOption(value: 1, label: '1/2'),
        ScaleOption(value: 2, label: '2/2'),
      ]),
      ScaleItem(id: 'mmse_8', question: 'Repetition (1 point)', maxScore: 1, options: [
        ScaleOption(value: 0, label: '0'), ScaleOption(value: 1, label: '1'),
      ]),
      ScaleItem(id: 'mmse_9', question: '3-stage command (3 points)', maxScore: 3, options: [
        ScaleOption(value: 0, label: '0/3'), ScaleOption(value: 1, label: '1/3'),
        ScaleOption(value: 2, label: '2/3'), ScaleOption(value: 3, label: '3/3'),
      ]),
      ScaleItem(id: 'mmse_10', question: 'Reading (1 point)', maxScore: 1, options: [
        ScaleOption(value: 0, label: '0'), ScaleOption(value: 1, label: '1'),
      ]),
      ScaleItem(id: 'mmse_11', question: 'Writing (1 point)', maxScore: 1, options: [
        ScaleOption(value: 0, label: '0'), ScaleOption(value: 1, label: '1'),
      ]),
      ScaleItem(id: 'mmse_12', question: 'Copying (1 point)', maxScore: 1, options: [
        ScaleOption(value: 0, label: '0'), ScaleOption(value: 1, label: '1'),
      ]),
    ],
    severityLevels: [
      SeverityLevel(name: 'No impairment', minScore: 27, maxScore: 30, description: 'No cognitive impairment', riskLevel: RiskLevel.none),
      SeverityLevel(name: 'Mild impairment', minScore: 21, maxScore: 26, description: 'Mild cognitive impairment', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Moderate impairment', minScore: 11, maxScore: 20, description: 'Moderate cognitive impairment', riskLevel: RiskLevel.moderate),
      SeverityLevel(name: 'Severe impairment', minScore: 0, maxScore: 10, description: 'Severe cognitive impairment', riskLevel: RiskLevel.severe),
    ],
  );

  // C-SSRS: Columbia-Suicide Severity Rating Scale
  static const ScaleDefinition cssrs = ScaleDefinition(
    type: ScaleType.cssrs,
    name: 'C-SSRS',
    description: 'Columbia-Suicide Severity Rating Scale for suicide risk assessment',
    maxScore: 25,
    items: [
      ScaleItem(
        id: 'cssrs_1',
        question: 'Wish to be dead',
        description: 'Thoughts about wanting to be dead or not alive',
        maxScore: 1,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes'),
        ],
      ),
      ScaleItem(
        id: 'cssrs_2',
        question: 'Non-specific active suicidal thoughts',
        description: 'Thoughts of killing oneself without a specific plan',
        maxScore: 1,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes'),
        ],
      ),
      ScaleItem(
        id: 'cssrs_3',
        question: 'Active suicidal ideation with method (no intent)',
        description: 'Thoughts of killing oneself with a specific method but no intent',
        maxScore: 1,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes'),
        ],
      ),
      ScaleItem(
        id: 'cssrs_4',
        question: 'Active suicidal ideation with some intent',
        description: 'Thoughts of killing oneself with some intent to act',
        maxScore: 1,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes'),
        ],
      ),
      ScaleItem(
        id: 'cssrs_5',
        question: 'Active suicidal ideation with specific plan and intent',
        description: 'Thoughts of killing oneself with a specific plan and intent',
        maxScore: 1,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes'),
        ],
      ),
      ScaleItem(
        id: 'cssrs_6',
        question: 'Suicidal behavior - Preparatory acts',
        description: 'Actions taken to prepare for a suicide attempt',
        maxScore: 1,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes'),
        ],
      ),
      ScaleItem(
        id: 'cssrs_7',
        question: 'Suicidal behavior - Aborted attempt',
        description: 'Started to attempt suicide but stopped before injury',
        maxScore: 1,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes'),
        ],
      ),
      ScaleItem(
        id: 'cssrs_8',
        question: 'Suicidal behavior - Interrupted attempt',
        description: 'Attempt was interrupted by another person',
        maxScore: 1,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes'),
        ],
      ),
      ScaleItem(
        id: 'cssrs_9',
        question: 'Actual suicide attempt',
        description: 'Engaged in self-destructive behavior with intent to die',
        maxScore: 5,
        options: [
          ScaleOption(value: 0, label: 'No'),
          ScaleOption(value: 1, label: 'Yes, low lethality'),
          ScaleOption(value: 2, label: 'Yes, moderate lethality'),
          ScaleOption(value: 3, label: 'Yes, high lethality'),
          ScaleOption(value: 4, label: 'Yes, very high lethality'),
          ScaleOption(value: 5, label: 'Yes, resulted in medical damage'),
        ],
      ),
    ],
    severityLevels: [
      SeverityLevel(name: 'Low Risk', minScore: 0, maxScore: 1, description: 'Low suicide risk - passive thoughts only', riskLevel: RiskLevel.mild),
      SeverityLevel(name: 'Moderate Risk', minScore: 2, maxScore: 4, description: 'Moderate suicide risk - active ideation', riskLevel: RiskLevel.moderate),
      SeverityLevel(name: 'High Risk', minScore: 5, maxScore: 9, description: 'High suicide risk - plan or intent', riskLevel: RiskLevel.severe),
      SeverityLevel(name: 'Very High Risk', minScore: 10, maxScore: 25, description: 'Very high suicide risk - recent attempt or preparatory behavior', riskLevel: RiskLevel.critical),
    ],
  );
}