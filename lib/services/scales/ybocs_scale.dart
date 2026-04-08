import 'scale_support.dart';

List<ScaleItem> get ybocsItems => [
      ybocsScaleItem('obs_time', 'Time occupied by obsessions'),
      ybocsScaleItem('obs_interference', 'Interference from obsessions'),
      ybocsScaleItem('obs_distress', 'Distress from obsessions'),
      ybocsScaleItem('obs_resistance', 'Resistance to obsessions'),
      ybocsScaleItem('obs_control', 'Control over obsessions'),
      ybocsScaleItem('comp_time', 'Time occupied by compulsions'),
      ybocsScaleItem('comp_interference', 'Interference from compulsions'),
      ybocsScaleItem('comp_distress', 'Distress from compulsions'),
      ybocsScaleItem('comp_resistance', 'Resistance to compulsions'),
      ybocsScaleItem('comp_control', 'Control over compulsions'),
    ];

String ybocsSeverity(int score) => normalMildModerateSevereVerySevere(score, const [7, 15, 23, 31]);
