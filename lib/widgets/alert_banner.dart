import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';

/// Alert banner for risk/severity warnings.
class AlertBanner extends StatelessWidget {
  final String riskLevel;
  final String message;
  final VoidCallback? onDismiss;

  const AlertBanner({
    super.key,
    required this.riskLevel,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(riskLevel);
    final isCritical = riskLevel == AppConstants.riskCritical;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: isCritical ? 2 : 1),
        boxShadow: isCritical
            ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]
            : null,
      ),
      child: ListTile(
        leading: Icon(
          isCritical ? Icons.emergency : Icons.warning_amber_rounded,
          color: color,
          size: 32,
        ),
        title: Text(
          riskLevel.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(color: color.withOpacity(0.9)),
        ),
        trailing: onDismiss != null
            ? IconButton(
                icon: Icon(Icons.close, color: color),
                onPressed: onDismiss,
              )
            : null,
      ),
    );
  }
}

/// Emergency alert dialog for critical/high risk patients.
void showEmergencyAlert(BuildContext context, String patientName, String risk) {
  final isCritical = risk == AppConstants.riskCritical;
  showDialog(
    context: context,
    barrierDismissible: !isCritical,
    builder: (ctx) => AlertDialog(
      backgroundColor: isCritical
          ? AppTheme.dangerColor.withOpacity(0.95)
          : AppTheme.warningColor.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.emergency, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Text(
            isCritical ? '🚨 CRITICAL ALERT' : '⚠️ HIGH RISK',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient: $patientName',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Immediate psychiatric evaluation required.\n'
            'Do NOT leave patient unattended.\n'
            'Alert treating team immediately.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ACKNOWLEDGE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
