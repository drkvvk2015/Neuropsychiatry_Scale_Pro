import 'scale_support.dart';

List<ScaleItem> get phq9Items => [
      phqScaleItem('anhedonia', 'Little interest or pleasure in doing things'),
      phqScaleItem('depressed_mood', 'Feeling down, depressed, or hopeless'),
      phqScaleItem('sleep', 'Trouble falling/staying asleep, or sleeping too much'),
      phqScaleItem('fatigue', 'Feeling tired or having little energy'),
      phqScaleItem('appetite', 'Poor appetite or overeating'),
      phqScaleItem('self_worth', 'Feeling bad about yourself or that you are a failure'),
      phqScaleItem('concentration', 'Trouble concentrating on things'),
      phqScaleItem('psychomotor', 'Moving/speaking slowly or being fidgety/restless'),
      phqScaleItem('suicidal', 'Thoughts that you would be better off dead or hurting yourself'),
    ];

String phq9Severity(int score) => normalMildModerateSevereVerySevere(score, const [4, 9, 14, 19]);
