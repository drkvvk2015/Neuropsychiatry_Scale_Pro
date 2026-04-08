import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../l10n/app_localizations_ext.dart';

/// Card widget showing a psychiatric scale with score and severity.
class ScaleCard extends StatelessWidget {
  final String scaleName;
  final int? score;
  final int maxScore;
  final String severity;
  final String riskLevel;
  final DateTime? assessedAt;
  final VoidCallback? onTap;

  const ScaleCard({
    super.key,
    required this.scaleName,
    this.score,
    required this.maxScore,
    this.severity = '',
    this.riskLevel = '',
    this.assessedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsExt.of(context);
    final hasScore = score != null;
    final displaySeverity = scaleName == AppConstants.scaleCSSRS ? riskLevel : severity;
    final severityColor = scaleName == AppConstants.scaleCSSRS
        ? AppTheme.riskColor(riskLevel)
        : AppTheme.severityColor(severity);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              // Scale icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _scaleAbbr(scaleName),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and status
              SizedBox(
                width: MediaQuery.sizeOf(context).width > 520 ? 340 : MediaQuery.sizeOf(context).width - 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scaleName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        )),
                    if (hasScore)
                      Text(
                        l10n.scoreLabel(maxScore > 0 ? '$score / $maxScore' : '$score'),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      )
                    else
                      Text(
                        l10n.tapToAssess,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    if (assessedAt != null)
                      Text(
                        _formatDate(assessedAt!),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              // Severity badge
              if (hasScore && displaySeverity.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: severityColor),
                  ),
                  child: Text(
                    scaleName == AppConstants.scaleCSSRS
                        ? l10n.riskLabel(displaySeverity)
                        : l10n.severityLabel(displaySeverity),
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _scaleAbbr(String name) {
    return name.replaceAll('-', '\n').replaceAll(' ', '\n');
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
