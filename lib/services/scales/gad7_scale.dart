import '../../core/constants.dart';
import 'scale_support.dart';

List<ScaleItem> get gad7Items => [
      phqScaleItem('nervous', 'Feeling nervous, anxious, or on edge'),
      phqScaleItem('worry_control', 'Not being able to stop or control worrying'),
      phqScaleItem('worry_various', 'Worrying too much about different things'),
      phqScaleItem('relaxing', 'Trouble relaxing'),
      phqScaleItem('restless', 'Being so restless that it is hard to sit still'),
      phqScaleItem('irritable', 'Becoming easily annoyed or irritable'),
      phqScaleItem('afraid', 'Feeling afraid, as if something awful might happen'),
    ];

String gad7Severity(int score) {
  if (score <= 4) return AppConstants.severityNormal;
  if (score <= 9) return AppConstants.severityMild;
  if (score <= 14) return AppConstants.severityModerate;
  return AppConstants.severitySevere;
}
