import '../../core/constants.dart';

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

ScaleItem standardScaleItem(String key, String question, int max) => ScaleItem(
      key: key,
      question: question,
      minScore: 1,
      maxScore: max,
      labels: List.generate(max, (index) => '${index + 1}'),
    );

ScaleItem phqScaleItem(String key, String question) => ScaleItem(
      key: key,
      question: question,
      minScore: 0,
      maxScore: 3,
      labels: const ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
    );

const ybocsLabels = ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'];

ScaleItem ybocsScaleItem(String key, String question) => ScaleItem(
      key: key,
      question: question,
      minScore: 0,
      maxScore: 4,
      labels: ybocsLabels,
    );

String severityForRange({
  required int score,
  required List<int> cutoffs,
  required List<String> labels,
}) {
  for (var index = 0; index < cutoffs.length; index++) {
    if (score <= cutoffs[index]) {
      return labels[index];
    }
  }
  return labels.last;
}

String normalMildModerateSevereVerySevere(int score, List<int> cutoffs) => severityForRange(
      score: score,
      cutoffs: cutoffs,
      labels: const [
        AppConstants.severityNormal,
        AppConstants.severityMild,
        AppConstants.severityModerate,
        AppConstants.severitySevere,
        AppConstants.severityVerySevere,
      ],
    );
