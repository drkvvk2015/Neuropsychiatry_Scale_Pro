import 'scale_support.dart';

List<ScaleItem> get hamdItems => [
      standardScaleItem('depressed_mood', 'Depressed Mood', 4),
      standardScaleItem('guilt', 'Guilt', 4),
      standardScaleItem('suicide', 'Suicide', 4),
      standardScaleItem('insomnia_early', 'Insomnia (Early)', 2),
      standardScaleItem('insomnia_middle', 'Insomnia (Middle)', 2),
      standardScaleItem('insomnia_late', 'Insomnia (Late)', 2),
      standardScaleItem('work_activities', 'Work & Activities', 4),
      standardScaleItem('retardation', 'Psychomotor Retardation', 4),
      standardScaleItem('agitation', 'Agitation', 4),
      standardScaleItem('anxiety_psychic', 'Anxiety (Psychic)', 4),
      standardScaleItem('anxiety_somatic', 'Anxiety (Somatic)', 4),
      standardScaleItem('somatic_gi', 'Somatic GI Symptoms', 2),
      standardScaleItem('somatic_general', 'Somatic General', 2),
      standardScaleItem('genital', 'Genital Symptoms', 2),
      standardScaleItem('hypochondriasis', 'Hypochondriasis', 4),
      standardScaleItem('weight_loss', 'Weight Loss', 2),
      standardScaleItem('insight', 'Insight', 2),
    ];

String hamdSeverity(int score) => normalMildModerateSevereVerySevere(score, const [7, 13, 18, 22]);
