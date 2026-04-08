export 'scales/scale_support.dart' show ScaleItem;

import '../core/constants.dart';
import 'scales/bprs_scale.dart' as bprs_scale;
import 'scales/cssrs_scale.dart' as cssrs_scale;
import 'scales/gad7_scale.dart' as gad7_scale;
import 'scales/hamd_scale.dart' as hamd_scale;
import 'scales/mmse_scale.dart' as mmse_scale;
import 'scales/phq9_scale.dart' as phq9_scale;
import 'scales/scale_support.dart';
import 'scales/ybocs_scale.dart' as ybocs_scale;
import 'scales/ymrs_scale.dart' as ymrs_scale;

/// Centralized scoring engine for all psychiatric scales.
class ScoringEngine {
  static List<ScaleItem> get bprsItems => bprs_scale.bprsItems;
  static List<ScaleItem> get phq9Items => phq9_scale.phq9Items;
  static List<ScaleItem> get gad7Items => gad7_scale.gad7Items;
  static List<ScaleItem> get hamdItems => hamd_scale.hamdItems;
  static List<ScaleItem> get ymrsItems => ymrs_scale.ymrsItems;
  static List<ScaleItem> get ybocsItems => ybocs_scale.ybocsItems;
  static List<ScaleItem> get mmseItems => mmse_scale.mmseItems;
  static List<ScaleItem> get cssrsItems => cssrs_scale.cssrsItems;

  static String bprsSeverity(int score) => bprs_scale.bprsSeverity(score);
  static String phq9Severity(int score) => phq9_scale.phq9Severity(score);
  static String gad7Severity(int score) => gad7_scale.gad7Severity(score);
  static String hamdSeverity(int score) => hamd_scale.hamdSeverity(score);
  static String ymrsSeverity(int score) => ymrs_scale.ymrsSeverity(score);
  static String ybocsSeverity(int score) => ybocs_scale.ybocsSeverity(score);
  static String mmseSeverity(int score) => mmse_scale.mmseSeverity(score);
  static String cssrsRisk(Map<String, int> scores) => cssrs_scale.cssrsRisk(scores);

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
}
